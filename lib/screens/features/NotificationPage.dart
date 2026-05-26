import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:fue_connect/widgets/filter_pills.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String _selectedCategory = "All";
  String _searchQuery = "";

  final List<String> _categories = [
    "All",
    "Application",
    "Club",
    "Event",
    "System",
  ];

  String get currentUid => FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  void initState() {
    super.initState();
    _createWelcomeNotificationIfNeeded();
  }

  Future<void> _createWelcomeNotificationIfNeeded() async {
    try {
      if (currentUid.isEmpty) return;

      final existingWelcome = await FirebaseFirestore.instance
          .collection('Notifications')
          .where('receiverId', isEqualTo: currentUid)
          .where('notification_type', isEqualTo: 'System')
          .limit(1)
          .get();

      if (existingWelcome.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('Notifications').add({
          'receiverId': currentUid,
          'notification_message': 'Welcome to FUE Connect!',
          'notification_type': 'System',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Welcome notification error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xffb1170c),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search notifications...',
                prefixIcon: const Icon(Icons.search, color: Color(0xffb1170c)),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Notifications')
                  .where('receiverId', isEqualTo: currentUid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs =
                    snapshot.data?.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final type = (data['notification_type'] ?? '')
                          .toString()
                          .toLowerCase();

                      final message = (data['notification_message'] ?? '')
                          .toString()
                          .toLowerCase();

                      final categoryMatch =
                          _selectedCategory == "All" ||
                          type == _selectedCategory.toLowerCase();

                      final searchMatch = message.contains(_searchQuery);

                      return categoryMatch && searchMatch;
                    }).toList() ??
                    [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications found',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];

                    final data = doc.data() as Map<String, dynamic>;

                    final bool isRead = data['isRead'] ?? false;

                    final Timestamp? timestamp =
                        data['timestamp'] as Timestamp?;

                    final DateTime date = timestamp?.toDate() ?? DateTime.now();

                    final String message = data['notification_message'] ?? '';

                    final String type = data['notification_type'] ?? '';

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: isRead ? Colors.white : const Color(0xfffdf2f1),

                        borderRadius: BorderRadius.circular(12),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),

                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),

                        leading: CircleAvatar(
                          backgroundColor: isRead
                              ? Colors.grey.shade200
                              : const Color(0xffb1170c),

                          child: Icon(
                            _getIconForType(type),
                            color: isRead ? Colors.grey : Colors.white,
                          ),
                        ),

                        title: Text(
                          message,
                          style: TextStyle(
                            fontWeight: isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(DateFormat('MMM d, h:mm a').format(date)),
                        ),

                        trailing: !isRead
                            ? const CircleAvatar(
                                radius: 4,
                                backgroundColor: Color(0xffb1170c),
                              )
                            : null,

                        onTap: () async {
                          if (!isRead) {
                            await doc.reference.update({'isRead': true});
                          }

                          if (!mounted) {
                            return;
                          }

                          _showNotificationDetails(
                            context,
                            type,
                            message,
                            date,
                          );
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

  void _showNotificationDetails(
    BuildContext context,
    String type,
    String message,
    DateTime date,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),

          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 24),

              CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xffb1170c),
                child: Icon(
                  _getIconForType(type),
                  color: Colors.white,
                  size: 32,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                type,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),

              const SizedBox(height: 16),

              Text(
                DateFormat('MMMM d, yyyy • h:mm a').format(date),
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffb1170c),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'application':
        return Icons.assignment_turned_in_rounded;

      case 'club':
        return Icons.groups_rounded;

      case 'event':
        return Icons.event_rounded;

      case 'system':
        return Icons.info_outline_rounded;

      default:
        return Icons.notifications_active_outlined;
    }
  }
}
