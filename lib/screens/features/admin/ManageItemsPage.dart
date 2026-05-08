import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:fue_connect/screens/features/admin/AddItemsPage.dart';

class ManageItemsPage extends StatefulWidget {
  final String title;
  final String collectionPath; 

  const ManageItemsPage({
    super.key, 
    required this.title, 
    required this.collectionPath
  });

  @override
  State<ManageItemsPage> createState() => _ManageItemsPageState();
}

class _ManageItemsPageState extends State<ManageItemsPage> {
  
  void deleteItem(String docId) async {
    bool confirm = await _showDeleteDialog();
    if (confirm) {
      // delete item mn el selected collection
      await FirebaseFirestore.instance
          .collection(widget.collectionPath)
          .doc(docId)
          .delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item deleted successfully")),
        );
      }
    }
  }

  // confirm ma3 el user before deleting
  Future<bool> _showDeleteDialog() async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Item?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    const Color fueRed = Color(0xffb1170c);

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title} Management"),
        backgroundColor: fueRed,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // listen to Firestore changes in real time
        stream: FirebaseFirestore.instance
            .collection(widget.collectionPath)
            .snapshots(),        
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          print("Docs count: ${docs.length}");

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.inbox, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No items yet"),
                  Text("Tap + to add new data", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );          
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              // get document data as map
              final data = docs[index].data() as Map<String, dynamic>;
              final String docId = docs[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                elevation: 3,
                child: ListTile(
                  leading: data['imageUrl'] != null 
                    ? Image.network(data['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 40),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          // law title msh mawgood y5od name, law el etneen msh mawgoodeen: "No Title"
                          data['title'] ?? data['name'] ?? 'No Title',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data['type'] ?? '',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['description'] ?? data['Description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['type'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditItemPage(
                              collectionPath: widget.collectionPath,
                              docId: docId,
                              itemData: data,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: fueRed),
                        tooltip: "Delete",
                        onPressed: () => deleteItem(docId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: fueRed,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditItemPage(collectionPath: widget.collectionPath),
          ),
        ),
      ),
    );
  }
}