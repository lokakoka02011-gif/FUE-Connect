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

  // Matches your Firestore "studentRef" format exactly
  String get studentPath =>
      "/Students/${FirebaseAuth.instance.currentUser?.uid}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xffb1170c),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Category Filter Section
          Container(
            color: const Color(0xffb1170c),
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories.map((cat) {
                  bool isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: Colors.white,
                      backgroundColor: Colors.white24,
                      labelStyle: TextStyle(
                        color:
                            isSelected ? const Color(0xffb1170c) : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) =>
                          setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 2. Dynamic Notification List
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
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No notifications for you yet."));
                }

                // Filter by category locally
                final docs = snapshot.data!.docs.where((doc) {
                  if (_selectedCategory == "All") return true;
                  String type =
                      doc['notification_type'].toString().replaceAll('"', '');
                  return type.toLowerCase() == _selectedCategory.toLowerCase();
                }).toList();

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    // Logic: If isRead doesn't exist in Firebase yet, treat as false (unread)
                    bool isRead =
                        data.containsKey('isRead') ? data['isRead'] : false;

                    DateTime dt = (data['timestamp'] as Timestamp).toDate();
                    String timeLabel =
                        DateFormat('jm').format(dt); // e.g. 5:47 PM

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      elevation: isRead ? 0 : 2,
                      color: isRead ? Colors.grey[50] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isRead
                              ? Colors.transparent
                              : const Color(0xffb1170c).withOpacity(0.2),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isRead
                              ? Colors.grey[300]
                              : const Color(0xffb1170c),
                          child: Icon(
                            isRead
                                ? Icons.notifications_none
                                : Icons.notifications_active,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          data['notification_message'] ?? "",
                          style: TextStyle(
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(data['notification_type']
                                    ?.toString()
                                    .replaceAll('"', '') ??
                                ""),
                            const Text(" • "),
                            Text(timeLabel),
                          ],
                        ),
                        onTap: () {
                          // AUTOMATION: Click updates Firebase without you doing anything
                          doc.reference.update({'isRead': true});
                        },
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
