import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String _searchQuery = "";
  bool _showAllForTesting = false; // Toggle this to see if the database is connecting

  @override
  Widget build(BuildContext context) {
    final String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          // This button is just for you to test during development!
          IconButton(
            icon: Icon(_showAllForTesting ? Icons.bug_report : Icons.person_search),
            onPressed: () {
              setState(() => _showAllForTesting = !_showAllForTesting);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_showAllForTesting ? "Showing ALL (Debug Mode)" : "Showing YOURS only")),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: const InputDecoration(
                labelText: "Search notifications",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // 2. Real-time Notification Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _showAllForTesting 
                ? FirebaseFirestore.instance.collection('Notifications').snapshots()
                : FirebaseFirestore.instance
                    .collection('Notifications')
                    .where('studentRef', isEqualTo: currentUserUid)
                    .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter local results based on search query
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final message = (data['notification_message'] ?? "").toString().toLowerCase();
                  final type = (data['notification_type'] ?? "").toString().toLowerCase();
                  return message.contains(_searchQuery) || type.contains(_searchQuery);
                }).toList();

                // Manual sort by timestamp
                docs.sort((a, b) {
                  Timestamp t1 = (a.data() as Map<String, dynamic>)['timestamp'] ?? Timestamp.now();
                  Timestamp t2 = (b.data() as Map<String, dynamic>)['timestamp'] ?? Timestamp.now();
                  return t2.compareTo(t1);
                });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(_showAllForTesting 
                          ? "Database collection is empty!" 
                          : "No notifications for your UID."),
                        Text("UID: $currentUserUid", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    final String message = data['notification_message'] ?? "No Message";
                    final String type = data['notification_type'] ?? "General";
                    final bool isRead = data['isRead'] ?? false;
                    
                    String timeLabel = "Just now";
                    if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
                      final DateTime date = (data['timestamp'] as Timestamp).toDate();
                      timeLabel = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
                    }

                    return ListTile(
                      tileColor: isRead ? Colors.white : const Color(0xfffff5f5), // Very light red
                      leading: CircleAvatar(
                        backgroundColor: _getIconColor(type),
                        child: Icon(_getIcon(type), color: Colors.white, size: 20),
                      ),
                      title: Text(
                        message,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text("$type • $timeLabel"),
                      trailing: !isRead 
                        ? const Icon(Icons.circle, color: Color(0xffb1170c), size: 12) 
                        : null,
                      onTap: () {
                        FirebaseFirestore.instance
                            .collection('Notifications')
                            .doc(doc.id)
                            .update({'isRead': true});
                      },
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

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'club': return Icons.group;
      case 'event': return Icons.event;
      case 'application': return Icons.assignment_turned_in;
      default: return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'club': return Colors.blue;
      case 'event': return Colors.orange;
      case 'application': return Colors.green;
      default: return const Color(0xffb1170c);
    }
  }
}