import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        searchQuery = "";
      });
      return;
    }

    setState(() {
      isLoading = true;
      searchQuery = query;
    });

    // Helping the search by capitalizing the first letter (e.g., 'robo' -> 'Robo')
    String formattedQuery = query.trim();
    if (formattedQuery.isNotEmpty) {
      formattedQuery = formattedQuery[0].toUpperCase() + formattedQuery.substring(1);
    }

    List<Map<String, dynamic>> tempResults = [];

    try {
      // 1. Search Clubs (Field: 'name')
      var clubSnap = await FirebaseFirestore.instance
          .collection('Clubs')
          .where('name', isGreaterThanOrEqualTo: formattedQuery)
          .where('name', isLessThanOrEqualTo: '$formattedQuery\uf8ff')
          .get();
      for (var doc in clubSnap.docs) {
        var data = doc.data();
        data['displayTitle'] = data['name']; // Standardizing for the UI
        data['origin'] = 'Clubs';
        tempResults.add(data);
      }

      // 2. Search Events (Field: 'name')
      var eventSnap = await FirebaseFirestore.instance
          .collection('Events')
          .where('name', isGreaterThanOrEqualTo: formattedQuery)
          .where('name', isLessThanOrEqualTo: '$formattedQuery\uf8ff')
          .get();
      for (var doc in eventSnap.docs) {
        var data = doc.data();
        data['displayTitle'] = data['name']; 
        data['origin'] = 'Events';
        tempResults.add(data);
      }

      // 3. Search Opportunity (Field: 'Title' - Capital T)
      var oppSnap = await FirebaseFirestore.instance
          .collection('Opportunity')
          .where('Title', isGreaterThanOrEqualTo: formattedQuery)
          .where('Title', isLessThanOrEqualTo: '$formattedQuery\uf8ff')
          .get();
      for (var doc in oppSnap.docs) {
        var data = doc.data();
        data['displayTitle'] = data['Title'];
        data['origin'] = 'Opportunity';
        tempResults.add(data);
      }
    } catch (e) {
      debugPrint("Search Error: $e");
    }

    setState(() {
      searchResults = tempResults;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color fueRed = Color(0xffb1170c);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search FUE Connect"),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: fueRed,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search clubs, events, or jobs...",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch("");
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Results List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: fueRed))
                : searchResults.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final item = searchResults[index];
                          return _buildResultTile(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(Map<String, dynamic> item) {
    IconData icon;
    Color color;

    switch (item['origin']) {
      case 'Clubs':
        icon = Icons.groups_rounded;
        color = Colors.blue;
        break;
      case 'Events':
        icon = Icons.event_available_rounded;
        color = Colors.orange;
        break;
      default:
        icon = Icons.work_outline_rounded;
        color = Colors.green;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          item['displayTitle'] ?? "Untitled",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          item['origin'],
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          // Navigate to the correct page based on origin
          String route = '/${item['origin'].toLowerCase()}';
          if (item['origin'] == 'Opportunity') route = '/opportunities';
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.manage_search_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty ? "Find your favorite campus activities" : "No matches found for '$searchQuery'",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}