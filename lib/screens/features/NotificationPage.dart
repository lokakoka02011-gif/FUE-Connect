import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';
import 'package:fue_connect/widgets/filter_pills.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // currently selected notification category for filtering
  String _selectedCategory = "All";
  String _searchQuery = "";
  final List<String> _categories = [
    "All",
    "Application",
    "Club",
    "Event",
    "Opportunity"
  ];

  // reference path used to match notifications for current user
  String get currentUid => FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xffb1170c),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search notifications...',
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
          // category selector (lama ados yghayar el filter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // listen to notifications from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Notifications')
                  .where(
                    'receiverId', // simpler ID match is more reliable than path strings
                    isEqualTo: currentUid,
                  )
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: LoadingIndicator(),
                  );
                }

                // filter el notifications ala hasab el category localy to save reads
                final docs = snapshot.data?.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  String type = (data['notification_type'] ?? "")
                     .toString()
                     .toLowerCase();
                  String message = 
                    (data['notification_message']??"")
                      .toString()
                      .toLowerCase();

                  bool matchesCategory =
                      _selectedCategory == "All" ||
                      type == _selectedCategory.toLowerCase();
                  bool matchesSearch =
                      message.contains(_searchQuery);
                  return matchesCategory && matchesSearch;                    
                }).toList() ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, 
                             size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "No notifications in $_selectedCategory yet.",
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    // check law el notification read to change status
                    bool isRead = data['isRead'] ?? false;
                    
                    // handle server timestamp law lassa null
                    DateTime dt = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.white : const Color(0xfffdf2f1), // Light red tint for unread
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: isRead ? Colors.grey[200] : const Color(0xffb1170c),
                          child: Icon(
                            _getIconForType(data['notification_type']),
                            color: isRead ? Colors.grey : Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          data['notification_message'] ?? "",
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM d, h:mm a').format(dt),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        trailing: !isRead 
                          ? const CircleAvatar(radius: 4, backgroundColor: Color(0xffb1170c)) 
                          : null,
                        onTap: () => doc.reference.update({'isRead': true}),
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

  // convert notification type le icon 3ashan UI yb2a awdah
  IconData _getIconForType(dynamic type) {
    String t = type.toString().toLowerCase();
    if (t.contains("club")) return Icons.group_work_rounded;
    if (t.contains("event")) return Icons.event_note_rounded;
    if (t.contains("opp")) return Icons.work_outline_rounded;
    if (t.contains("app")) return Icons.assignment_turned_in_rounded;
    return Icons.notifications_active_outlined;
  }
}