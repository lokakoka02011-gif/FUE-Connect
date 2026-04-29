import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String _selectedCategory = "All";
  final List<String> _categories = [
    "All",
    "Application",
    "Club",
    "Event",
    "Opportunity"
  ];

  String get studentPath => "/Students/${FirebaseAuth.instance.currentUser?.uid}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xffb1170c),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. IMPROVED CATEGORY BAR (Matches your Screenshot)
          Container(
            height: 60,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xffb1170c) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xffb1170c), // Always red border
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          if (isSelected)
                            const Icon(Icons.check, color: Colors.white, size: 16),
                          if (isSelected) const SizedBox(width: 5),
                          Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. DYNAMIC NOTIFICATION LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Notifications')
                  .where('studentRef', isEqualTo: studentPath)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // Filter locally
                final docs = snapshot.data?.docs.where((doc) {
                  if (_selectedCategory == "All") return true;
                  String type = doc['notification_type'].toString().replaceAll('"', '');
                  return type.toLowerCase() == _selectedCategory.toLowerCase();
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
                          "No $_selectedCategory notifications yet.",
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
                    bool isRead = data['isRead'] ?? false;
                    DateTime dt = (data['timestamp'] as Timestamp).toDate();

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

  // Helper to make the list look organized with icons
  IconData _getIconForType(dynamic type) {
    String t = type.toString().toLowerCase();
    if (t.contains("club")) return Icons.group_work_rounded;
    if (t.contains("event")) return Icons.event_note_rounded;
    if (t.contains("opp")) return Icons.work_outline_rounded;
    if (t.contains("app")) return Icons.assignment_turned_in_rounded;
    return Icons.notifications_active_outlined;
  }
}