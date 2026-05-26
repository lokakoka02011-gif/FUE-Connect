import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:fue_connect/screens/features/jobsPage.dart';
import 'package:fue_connect/screens/features/internshipsPage.dart';
import 'package:fue_connect/screens/features/ClubsPage.dart';
import 'package:fue_connect/screens/features/EventsPage.dart';
import 'package:fue_connect/screens/features/VolunteerPage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = "";
  String _selectedCategory = "All";

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _recentlyViewed = [];
  List<Map<String, dynamic>> _recommendedItems = [];

  List<String> _recentSearches = [];

  bool _isSearchFocused = false;
  bool _isLoading = false;

  final List<String> _categories = [
    "All",
    "Clubs",
    "Events",
    "Jobs",
    "Internships",
  ];

  @override
  void initState() {
    super.initState();

    _loadRecentlyViewed();
    _loadRecentSearches();
    _loadRecommendations();

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // save & load recently viewed items
  Future<void> _loadRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();

    final String? recentData = prefs.getString('recent_viewed');

    if (recentData != null) {
      setState(() {
        _recentlyViewed = List<Map<String, dynamic>>.from(
          json.decode(recentData),
        );
      });
    }
  }

  // load recent searches
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();

    final recentSearches = prefs.getStringList('recent_search_queries');

    if (recentSearches != null) {
      setState(() {
        _recentSearches = recentSearches;
      });
    }
  }

  // load recommendations
  Future<void> _loadRecommendations() async {
    List<Map<String, dynamic>> recommendations = [];

    try {
      var eventSnap = await FirebaseFirestore.instance
          .collection('Events')
          .limit(2)
          .get();

      for (var doc in eventSnap.docs) {
        var data = doc.data();

        data['displayTitle'] =
            data['name'] ??
            data['title'] ??
            "Untitled";
        data['origin'] = 'Events';
        data['docId'] = doc.id;

        recommendations.add(data);
      }

      var clubSnap = await FirebaseFirestore.instance
          .collection('Clubs')
          .limit(2)
          .get();

      for (var doc in clubSnap.docs) {
        var data = doc.data();

        data['displayTitle'] = data['name'];

        data['origin'] = 'Clubs';
        data['docId'] = doc.id;

        recommendations.add(data);
      }

      var oppSnap = await FirebaseFirestore.instance
          .collection('Opportunity')
          .get();

      for (var doc in oppSnap.docs) {
        var data = doc.data();

        String type =
            (data['type'] ?? "").toString().toLowerCase();

        data['displayTitle'] = data['Title'];

        if (type == "job") {
          data['origin'] = 'Jobs';
        } else if (type == "internship") {
          data['origin'] = 'Internships';
        } else {
          continue;
        }

        data['docId'] = doc.id;

        recommendations.add(data);
      }
    } catch (e) {
      debugPrint("Recommendation Error: $e");
    }

    setState(() {
      _recommendedItems = recommendations;
    });
  }

  // save recent search query
  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    _recentSearches.remove(query);

    _recentSearches.insert(0, query);

    if (_recentSearches.length > 8) {
      _recentSearches.removeLast();
    }

    await prefs.setStringList('recent_search_queries', _recentSearches);

    setState(() {});
  }

  // add item lel recently viewed
  Future<void> _addToRecent(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove duplicates to move the item to the top
    _recentlyViewed.removeWhere(
      (element) =>
          element['displayTitle'] == item['displayTitle'] &&
          element['origin'] == item['origin'],
    );

    _recentlyViewed.insert(0, item);

    // keep list akher 5 items only for manageablity
    if (_recentlyViewed.length > 5) {
      _recentlyViewed.removeLast();
    }

    await prefs.setString('recent_viewed', json.encode(_recentlyViewed));

    setState(() {});
  }

  // search fel clubs w events w opportunities
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
      // Search clubs
      if (_selectedCategory == "All" || _selectedCategory == "Clubs") {
        var clubSnap = await FirebaseFirestore.instance
            .collection('Clubs')
            .get();

        for (var doc in clubSnap.docs) {
          var data = doc.data();

          String name = (data['name'] ?? "").toString().toLowerCase();

          if (name.contains(_searchQuery)) {
            data['displayTitle'] = data['name'];

            data['origin'] = 'Clubs';

            data['docId'] = doc.id;

            tempResults.add(data);
          }
        }
      }

      // Search events
      if (_selectedCategory == "All" || _selectedCategory == "Events") {
        var eventSnap = await FirebaseFirestore.instance
            .collection('Events')
            .get();

        for (var doc in eventSnap.docs) {
          var data = doc.data();

          String name = (data['name'] ?? "").toString().toLowerCase();

          if (name.contains(_searchQuery)) {
            data['displayTitle'] = data['name'];

            data['origin'] = 'Events';

            data['docId'] = doc.id;

            tempResults.add(data);
          }
        }
      }
            
      // Search Jobs & Internships
      if (_selectedCategory == "All" ||
          _selectedCategory == "Jobs" ||
          _selectedCategory == "Internships") {

        var oppSnap = await FirebaseFirestore.instance
            .collection('Opportunity')
            .get();

        for (var doc in oppSnap.docs) {
          var data = doc.data();

          String title =
              (data['Title'] ?? "").toString().toLowerCase();

          String type =
              (data['type'] ?? "").toString().toLowerCase();

          if (title.contains(_searchQuery)) {

            if (_selectedCategory == "Jobs" &&
                type != "job") {
              continue;
            }

            if (_selectedCategory == "Internships" &&
                type != "internship") {
              continue;
            }

            data['displayTitle'] = data['Title'];

            data['origin'] =
                type == "job"
                    ? "Jobs"
                    : "Internships";

            data['docId'] = doc.id;

            tempResults.add(data);
          }
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

    void _handleNavigation(Map<String, dynamic> item) {

      _saveRecentSearch(_searchController.text);

      Widget destination;

      switch (item['origin']) {

        case 'Clubs':
          destination = const ClubsPage();
          break;

        case 'Events':
          destination = const EventsPage();
          break;

        case 'Volunteer':
          destination = const VolunteerPage();
          break;

        case 'Jobs':
          destination = const JobsPage();
          break;

        case 'Internships':
          destination = const InternshipsPage();
          break;

        default:
          return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => destination,
        ),
      );
    }
  @override
  Widget build(BuildContext context) {
    const Color fueRed = Color(0xffb1170c);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text("Search FUE Connect"),

        elevation: 0,

        backgroundColor: fueRed,

        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // Header Search Bar
          Container(
            padding: const EdgeInsets.all(16),

            decoration: const BoxDecoration(
              color: fueRed,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),

            child: Column(
              children: [
                TextField(
                  controller: _searchController,

                  focusNode: _searchFocusNode,

                  onChanged: _performSearch,

                  onSubmitted: _saveRecentSearch,

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

                  const SizedBox(height: 14),

                  SizedBox(
                    height: 38,

                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,

                      itemCount: _categories.length,

                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),

                      itemBuilder: (context, index) {
                        final category = _categories[index];

                        final isSelected = _selectedCategory == category;

                        return GestureDetector(                                                    
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });

                            _performSearch(_searchController.text);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.15),

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Text(
                              category,

                              style: TextStyle(
                                color: isSelected ? fueRed : Colors.white,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator(color: fueRed))
                : _searchQuery.isEmpty
                ? _buildEmptyState()
                : _searchResults.isEmpty
                ? _buildNoResultsState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),

                    itemCount: _searchResults.length,

                    itemBuilder: (context, index) =>
                        _buildResultTile(_searchResults[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    // If the user clicked the search bar show search history
    if (_isSearchFocused) {
      return ListView(
        children: [
          if (_recentSearches.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(20),

              child: Text(
                "Search History",

                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            ..._recentSearches.map(
              (search) => ListTile(
                leading: const Icon(Icons.history),

                title: Text(search),

                onTap: () {
                  _searchController.text = search;

                  _performSearch(search);
                },
              ),
            ),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),

                child: Text("Type to find clubs, events, or jobs"),
              ),
            ),
          ],
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(children: [_buildRecommendedSection()]),
    );
  }

  Widget _buildResultTile(Map<String, dynamic> item, {bool isRecent = false}) {
    Color originColor;
    IconData icon;

    switch (item['origin']) {
      case 'Clubs':
        originColor = Colors.blue;
        icon = Icons.groups;
        break;

      case 'Events':
        originColor = Colors.orange;
        icon = Icons.event;
        break;

      case 'Jobs':
        originColor = Colors.green;
        icon = Icons.work;
        break;

      case 'Internships':
        originColor = Colors.purple;
        icon = Icons.school;
        break;

      default:
        originColor = Colors.grey;
        icon = Icons.star;
    }

    return ListTile(
      leading: Icon(
        isRecent ? Icons.history : icon,

        color: isRecent ? Colors.grey : originColor,
      ),

      title: Text(
        item['displayTitle'] ?? "Untitled",

        style: const TextStyle(fontWeight: FontWeight.w500),
      ),

      subtitle: Text(
        item['origin'],

        style: TextStyle(color: originColor, fontSize: 12),
      ),

      trailing: const Icon(Icons.chevron_right, size: 18),

      onTap: () {
        _addToRecent(item);

        _saveRecentSearch(_searchController.text);

        _handleNavigation(item);
      },
    );
  }

  Widget _buildRecommendationCard({
    required String title,
    required String category,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(15),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),

            blurRadius: 10,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: color.withOpacity(0.1),

              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  category.toUpperCase(),

                  style: TextStyle(
                    color: color,

                    fontSize: 10,

                    fontWeight: FontWeight.bold,

                    letterSpacing: 1.1,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  title,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        ],
      ),
    );
  }

    Widget _buildRecommendedSection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          if (_recentlyViewed.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),

              child: Text(
                "Recently Viewed",

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            ..._recentlyViewed.map(
              (item) => _buildResultTile(item, isRecent: true),
            ),

            const SizedBox(height: 20),
          ],

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),

            child: Text(
              "Recommended For You",

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ..._recommendedItems.map((item) {
            Color color;
            IconData icon;

            switch (item['origin']) {
              case 'Clubs':
                color = Colors.blue;
                icon = Icons.groups;
                break;

              case 'Events':
                color = Colors.orange;
                icon = Icons.event;
                break;

              case 'Jobs':
                color = Colors.green;
                icon = Icons.work;
                break;

              case 'Internships':
                color = Colors.purple;
                icon = Icons.school;
                break;

              default:
                color = Colors.grey;
                icon = Icons.star;
            }

            return GestureDetector(
              onTap: () {
                _handleNavigation(item);
              },

              child: _buildRecommendationCard(
                title: item['displayTitle'] ?? "Untitled",
                category: item['origin'],
                color: color,
                icon: icon,
              ),
            );
          }).toList(),
        ],
      );
    }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),

          const SizedBox(height: 16),

          Text(
            "No matches for '$_searchQuery'",

            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
