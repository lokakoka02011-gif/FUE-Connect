import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({super.key});

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FUE Clubs')),
      body: Column(
        children: [
          // 1. SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search clubs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // 2. LIVE FIREBASE LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Listening to your 'Clubs' collection
              stream: FirebaseFirestore.instance
                  .collection('Clubs')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading data"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filtering the list based on the 'name' field in Firestore
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  // Safety check: using 'name' instead of 'title'
                  final clubName = (data['name'] ?? "").toString().toLowerCase();
                  return clubName.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No clubs found."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    
                    return _buildClubCard(
                      // Mapping to your Firestore field 'name'
                      name: data['name'] ?? "New Club",
                      description: data['description'] ?? "No description available",
                      imageUrl: data['imageUrl'] ?? "https://via.placeholder.com/150", 
                      isFeatured: data['isFeatured'] ?? false,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED DESIGN
  Widget _buildClubCard({
    required String name, 
    required String description, 
    required String imageUrl, 
    bool isFeatured = false
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isFeatured ? const BorderSide(color: Color(0xffb1170c), width: 2) : BorderSide.none,
      ),
      elevation: isFeatured ? 8 : 4,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              imageUrl, 
              height: isFeatured ? 180 : 120, 
              width: double.infinity, 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          ListTile(
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text(description, maxLines: 3, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Add navigation to club details here later
            },
          ),
        ],
      ),
    );
  }
}