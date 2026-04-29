import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _recentlyViewed = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecentlyViewed();
  }

  // --- PERSISTENCE LOGIC ---
  Future<void> _loadRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recentData = prefs.getString('recent_searches');
    if (recentData != null) {
      setState(() {
        _recentlyViewed = List<Map<String, dynamic>>.from(json.decode(recentData));
      });
    }
  }

  Future<void> _addToRecent(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove duplicates to move the item to the top
    _recentlyViewed.removeWhere((element) => 
        element['displayTitle'] == item['displayTitle'] && 
        element['origin'] == item['origin']);
    
    _recentlyViewed.insert(0, item);
    
    // Keep list manageable (last 5 items)
    if (_recentlyViewed.length > 5) _recentlyViewed.removeLast();

    await prefs.setString('recent_searches', json.encode(_recentlyViewed));
    setState(() {});
  }

  // --- SEARCH LOGIC (FIXED) ---
  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchQuery = "";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query.toLowerCase();
    });

    List<Map<String, dynamic>> tempResults = [];

    try {
      // Fetching collections and filtering locally to fix the "first letter" issue
      // 1. Search Clubs
      var clubSnap = await FirebaseFirestore.instance.collection('Clubs').get();
      for (var doc in clubSnap.docs) {
        var data = doc.data();
        String name = (data['name'] ?? "").toString().toLowerCase();
        if (name.contains(_searchQuery)) {
          data['displayTitle'] = data['name'];
          data['origin'] = 'Clubs';
          tempResults.add(data);
        }
      }

      // 2. Search Events
      var eventSnap = await FirebaseFirestore.instance.collection('Events').get();
      for (var doc in eventSnap.docs) {
        var data = doc.data();
        String name = (data['name'] ?? "").toString().toLowerCase();
        if (name.contains(_searchQuery)) {
          data['displayTitle'] = data['name'];
          data['origin'] = 'Events';
          tempResults.add(data);
        }
      }

      // 3. Search Opportunities
      var oppSnap = await FirebaseFirestore.instance.collection('Opportunity').get();
      for (var doc in oppSnap.docs) {
        var data = doc.data();
        String title = (data['Title'] ?? "").toString().toLowerCase();
        if (title.contains(_searchQuery)) {
          data['displayTitle'] = data['Title'];
          data['origin'] = 'Opportunity';
          tempResults.add(data);
        }
      }
    } catch (e) {
      debugPrint("Search Error: $e");
    }

    setState(() {
      _searchResults = tempResults;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color fueRed = Color(0xffb1170c);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Search FUE Connect"),
        elevation: 0,
        backgroundColor: fueRed,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: fueRed,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
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
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Dynamic Body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: fueRed))
                : _searchQuery.isEmpty
                    ? _buildEmptyState()
                    : _searchResults.isEmpty
                        ? _buildNoResultsState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) => _buildResultTile(_searchResults[index]),
                          ),
          ),
        ],
      ),
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recently Viewed
          if (_recentlyViewed.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 16, 10),
              child: Text("Recently Viewed", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ..._recentlyViewed.map((item) => _buildResultTile(item, isRecent: true)).toList(),
            const Divider(height: 40, indent: 20, endIndent: 20),
          ],

          // Recommended For You
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 16, 15),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text("Recommended for You", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _buildRecommendationCard(
            title: "Robotics Workshop 2024",
            category: "Events",
            color: Colors.orange,
            icon: Icons.precision_manufacturing,
          ),
          _buildRecommendationCard(
            title: "Business Analytics Club",
            category: "Clubs",
            color: Colors.blue,
            icon: Icons.insights,
          ),
          _buildRecommendationCard(
            title: "Junior Flutter Developer",
            category: "Opportunity",
            color: Colors.green,
            icon: Icons.code,
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(Map<String, dynamic> item, {bool isRecent = false}) {
    Color originColor;
    IconData icon;

    switch (item['origin']) {
      case 'Clubs': originColor = Colors.blue; icon = Icons.groups; break;
      case 'Events': originColor = Colors.orange; icon = Icons.event; break;
      default: originColor = Colors.green; icon = Icons.work;
    }

    return ListTile(
      leading: Icon(isRecent ? Icons.history : icon, color: isRecent ? Colors.grey : originColor),
      title: Text(item['displayTitle'] ?? "Untitled", style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(item['origin'], style: TextStyle(color: originColor, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () {
        _addToRecent(item);
        String route = '/${item['origin'].toLowerCase()}';
        if (item['origin'] == 'Opportunity') route = '/opportunities';
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildRecommendationCard({required String title, required String category, required Color color, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No matches for '$_searchQuery'", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}