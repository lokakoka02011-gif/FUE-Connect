import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fue_connect/screens/features/PostsPage.dart';
import 'package:fue_connect/widgets/filter_pills.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({super.key});

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  String _searchQuery = "";
  String _selectedCategory = "All";
  @override
  void initState() {
    super.initState();
    _loadSavedClubs();
  }
  
  final Set<String> _savedClubIds = {};

  final List<String> _categories = [
    'All',
    'Social',
    'Tech',
    'Charity',
    'Sports',
    'Academic',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('FUE Clubs'),
        backgroundColor: const Color(0xffb1170c),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),

            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },

              decoration: InputDecoration(
                hintText: 'Search clubs...',

                prefixIcon: const Icon(Icons.search, color: Color(0xffb1170c)),

                filled: true,
                fillColor: Colors.grey[100],

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),

                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // FILTERS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: FilterPills(
              options: _categories,
              selected: _selectedCategory,

              onSelected: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ),

          const SizedBox(height: 15),

          // CLUBS LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Clubs')
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading data"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final clubName = (data['name'] ?? "")
                      .toString()
                      .toLowerCase();

                  final category = (data['category'] ?? "")
                      .toString()
                      .toLowerCase();

                  bool matchesSearch = clubName.contains(_searchQuery);

                  bool matchesCategory =
                      _selectedCategory == "All" ||
                      category == _selectedCategory.toLowerCase();

                  return matchesSearch && matchesCategory;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No clubs found\nTry another category",

                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),

                  itemCount: docs.length,

                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    return _buildClubCard(context, data, docs[index].id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(
    BuildContext context,
    Map<String, dynamic> data,
    String docId,
  ) {
    bool isFeatured = data['isFeatured'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),

      elevation: isFeatured ? 6 : 2,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),

        side: isFeatured
            ? const BorderSide(color: Color(0xffb1170c), width: 1.5)
            : BorderSide.none,
      ),

      child: InkWell(
        onTap: () => _showClubDetails(context, data, docId),

        borderRadius: BorderRadius.circular(15),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // FEATURED TAG
              if (isFeatured)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xffb1170c),

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Text(
                    "FEATURED",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // CLUB NAME
              Text(
                data['name'] ?? "Club Name",

                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 8),

              // DESCRIPTION
              Text(
                data['description'] ?? "",

                maxLines: 2,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(color: Colors.grey[700]),
              ),

              const SizedBox(height: 14),

              // INFO ROW
              Row(
                children: [
                  const Icon(
                    Icons.category,
                    size: 16,
                    color: Color(0xffb1170c),
                  ),

                  const SizedBox(width: 5),

                  Text(
                    data['category'] ?? "General",

                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _savedClubIds.contains(docId)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: const Color(0xffb1170c),
                    ),
                    onPressed: () => _toggleSaveClub(docId, data),
                  ),

                  const Icon(Icons.people, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 4),

                  Text(
                    "${data['memberCount'] ?? 0} members",

                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(width: 10),

                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClubDetails(
    BuildContext context,
    Map<String, dynamic> data,
    String clubId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),

        padding: const EdgeInsets.all(24),

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,

                  decoration: BoxDecoration(
                    color: Colors.grey[300],

                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                data['name'] ?? 'Club Details',

                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              _detailRow(
                Icons.category,
                "Category: ",
                data['category'] ?? "General",
              ),

              _detailRow(
                Icons.people,
                "Members: ",
                "${data['memberCount'] ?? 'Join to see'}",
              ),

              const Divider(height: 30),

              const Text(
                "About the Club",

                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 5),

              Text(data['description'] ?? 'No description available.'),

              const SizedBox(height: 30),

              // JOIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffb1170c),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: () async {
                    try {
                      final user = FirebaseAuth.instance.currentUser;

                      await FirebaseFirestore.instance
                          .collection('clubApplications')
                          .add({
                            'clubId': clubId,
                            'clubName': data['name'],
                            'studentId': user?.uid,
                            'studentEmail': user?.email,
                            'appliedAt': Timestamp.now(),
                            'status': 'pending',
                          });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Applied successfully"),

                          backgroundColor: Color(0xffb1170c),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to apply: $e")),
                      );
                    }
                  },

                  child: const Text(
                    "Request to Join",

                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // POSTS BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,

                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xffb1170c)),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            PostsPage(clubName: data['name'] ?? 'Club'),
                      ),
                    );
                  },

                  child: const Text(
                    "View Posts",

                    style: TextStyle(color: Color(0xffb1170c), fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xffb1170c)),

          const SizedBox(width: 10),

          Text(label, style: const TextStyle(color: Colors.grey)),

          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
  Future<void> _loadSavedClubs() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('saved_items')
        .where('type', isEqualTo: 'club')
        .get();

    setState(() {
      _savedClubIds.addAll(
        snapshot.docs.map((doc) => doc.id),
      );
    });
  }
  Future<void> _toggleSaveClub(
    String docId,
    Map<String, dynamic> data,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final savedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('saved_items')
        .doc(docId);

    final doc = await savedRef.get();

    if (doc.exists) {
      await savedRef.delete();

      setState(() {
        _savedClubIds.remove(docId);
      });
    } else {
      await savedRef.set({
        'title': data['name'],
        'type': 'club',
        'route': '/clubs',
        'savedAt': Timestamp.now(),
      });

      setState(() {
        _savedClubIds.add(docId);
      });
    }
  }
}
