import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fue_connect/screens/features/ClubPostsPage.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({super.key});

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  String _searchQuery = "";
  String _selectedCategory = "All";
  final List<String> _categories = ['All', 'Social', 'Tech', 'Charity', 'Sports', 'Academic'];

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
          // 1. CONSISTENT SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
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

          // 2. CONSISTENT CATEGORY PILLS
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                String cat = _categories[index];
                bool isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xffb1170c) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xffb1170c), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 15),

          // 3. CLUBS LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Clubs').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading data"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xffb1170c)));
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final clubName = (data['name'] ?? "").toString().toLowerCase();
                  final category = data['category'] ?? "All";
                  
                  bool matchesSearch = clubName.contains(_searchQuery);
                  bool matchesCategory = _selectedCategory == "All" || category == _selectedCategory;
                  
                  return matchesSearch && matchesCategory;
                }).toList();

                if (docs.isEmpty) return const Center(child: Text("No clubs found."));

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

  Widget _buildClubCard(BuildContext context, Map<String, dynamic> data, String docId) {
    bool isFeatured = data['isFeatured'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isFeatured ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isFeatured ? const BorderSide(color: Color(0xffb1170c), width: 1.5) : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showClubDetails(context, data, docId),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    data['imageUrl'] ?? "https://via.placeholder.com/150",
                    height: isFeatured ? 160 : 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isFeatured)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xffb1170c),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text("FEATURED", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(data['name'] ?? "Club Name", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(data['description'] ?? "", maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showClubDetails(BuildContext context, Map<String, dynamic> data, String clubId) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text(data['name'] ?? 'Club Details', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _detailRow(Icons.category, "Category: ", data['category'] ?? "General"),
            _detailRow(Icons.people, "Members: ", "${data['memberCount'] ?? 'Join to see'}"),
            const Divider(height: 30),
            const Text("About the Club", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text(data['description'] ?? 'No description available.'),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffb1170c),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                child: const Text(
                  "Request to Join",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xffb1170c)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClubPostsPage(
                        clubId: clubId,
                        clubName: data['name'] ?? 'Club',
                      ),
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
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
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
}