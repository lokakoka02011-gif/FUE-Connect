import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';
import 'package:fue_connect/widgets/filter_pills.dart';

class SavedItemsPage extends StatefulWidget {
  const SavedItemsPage({super.key});
  @override
  State<SavedItemsPage> createState() =>
      _SavedItemsPageState();
  }
  class _SavedItemsPageState
      extends State<SavedItemsPage> {
  String _searchQuery = "";
  String _selectedType = "All";

  final List<String> _types = [
    'All',
    'Job',
    'Internship',
    'Volunteer',
    'Event',
    'Club',
  ];

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'Job':
        return Icons.work;

      case 'Internship':
        return Icons.school;

      case 'Volunteer':
        return Icons.volunteer_activism;

      case 'Event':
        return Icons.event;

      case 'Club':
        return Icons.groups;

      default:
        return Icons.bookmark;
    }
  }  

  @override
  Widget build(BuildContext context) {
      // get current user id 3ashan ngeeb saved items beta3to
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Items")),
      // listen lel saved items mn Firestore real-time
    body: Column(
      children: [

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (value) =>
                setState(() => _searchQuery = value.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search saved items...',
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xffb1170c),
              ),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilterPills(
            options: _types,
            selected: _selectedType,
            onSelected: (value) {
              setState(() {
                _selectedType = value;
              });
            },
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('saved_items')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LoadingIndicator());
          }
          // law mafish saved items nshow empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child:                 
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmarks_outlined,
                  size: 70,
                  color: Colors.grey[300],
                ),

                const SizedBox(height: 16),

                const Text(
                  "No saved items yet",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Save opportunities, clubs, events, and volunteering posts to view them here.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            )            
            );
          }

          final docs = snapshot.data!.docs.where((doc) {
            final data =
                doc.data() as Map<String, dynamic>;

            final title =
                (data['title'] ?? "")
                    .toString()
                    .toLowerCase();

            final type =
                (data['type'] ?? "").toString();

            return title.contains(_searchQuery) &&
                (_selectedType == "All" ||
                    type == _selectedType);
          }).toList();

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              // get saved item data as map
              var data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(

                leading: CircleAvatar(
                  backgroundColor: const Color(0xffb1170c),
                  child: Icon(
                    _getTypeIcon(data['type']),
                    color: Colors.white,
                  ),
                ),

                  title: Text(data['title'] ?? 'Untitled Item'),
                  subtitle: Text(data['type'] ?? 'General'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  // navigate lel page bta3et el item da  
                  onTap: () => Navigator.pushNamed(context, data['route'] ?? '/'),
                ),
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

}