import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fue_connect/widgets/filter_pills.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String _searchQuery = "";
  String _selectedCategory = "All";
  String _sortBy = "Upcoming";

  final Set<String> _savedEventIds = {};

  @override
  void initState() {
    super.initState();
    _loadSavedEvents();
  }

  final List<String> _categories = [
    'All',
    'Workshops',
    'Sports',
    'Tech',
    'Music',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('FUE Events'),
        backgroundColor: const Color(0xffb1170c),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(16.0),

            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },

              decoration: InputDecoration(
                hintText: 'Search events...',

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

          // HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  "Upcoming Events",

                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),

                  icon: const Icon(
                    Icons.sort,
                    color: Color(0xffb1170c),
                    size: 20,
                  ),

                  items: ['Upcoming', 'Popular'].map((String value) {
                    return DropdownMenuItem(
                      value: value,

                      child: Text(value, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),

                  onChanged: (val) {
                    setState(() {
                      _sortBy = val!;
                    });
                  },
                ),
              ],
            ),
          ),

          // EVENTS
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Events')
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading events"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicator());
                }

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs.where((
                  doc,
                ) {
                  final data = doc.data() as Map<String, dynamic>;

                  final name = (data['name'] ?? "").toString().toLowerCase();

                  final category = (data['category'] ?? "")
                      .toString()
                      .toLowerCase();

                  DateTime eventDate;

                  if (data['date'] != null && data['date'] is Timestamp) {
                    eventDate = (data['date'] as Timestamp).toDate();
                  } else {
                    eventDate = DateTime.now().add(const Duration(days: 365));
                  }

                  final bool isExpired = eventDate.isBefore(DateTime.now());

                  return name.contains(_searchQuery) &&
                      (_selectedCategory == "All" ||
                          category == _selectedCategory.toLowerCase()) &&
                      !isExpired;
                }).toList();

                // SORT
                if (_sortBy == "Upcoming") {
                  docs.sort((a, b) {
                    Timestamp aDate = a['date'] is Timestamp
                        ? a['date']
                        : Timestamp.now();

                    Timestamp bDate = b['date'] is Timestamp
                        ? b['date']
                        : Timestamp.now();

                    return aDate.compareTo(bDate);
                  });
                }

                if (docs.isEmpty) {
                  return const Center(child: Text("No events found."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    DateTime dt;

                    if (data['date'] != null && data['date'] is Timestamp) {
                      dt = (data['date'] as Timestamp).toDate();
                    } else {
                      dt = DateTime.now().add(const Duration(days: 365));
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),

                      elevation: 2,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),

                        onTap: () =>
                            _showEventDetails(context, data, docs[index].id),

                        child: Padding(
                          padding: const EdgeInsets.all(16),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                data['name'] ?? "Event",

                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                data['description'] ?? "",

                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,

                                style: TextStyle(color: Colors.grey[700]),
                              ),

                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                    color: Color(0xffb1170c),
                                  ),

                                  const SizedBox(width: 5),

                                  Text(
                                    DateFormat('MMM dd, yyyy').format(dt),

                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                    const Spacer(),

                                    IconButton(
                                      icon: Icon(
                                        _savedEventIds.contains(docs[index].id)
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: const Color(0xffb1170c),
                                      ),
                                      onPressed: () =>
                                          _toggleSaveEvent(docs[index].id, data),
                                    ),

                                    const Icon(
                                      Icons.people,
                                      size: 16,
                                      color: Colors.blueGrey,
                                    ),

                                  const SizedBox(width: 4),

                                  Text(
                                    "${data['participants'] ?? 0} joined",

                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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

  void _showEventDetails(
    BuildContext context,
    Map<String, dynamic> data,
    String eventId,
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
                data['name'] ?? 'Event',

                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              _detailRow(
                Icons.location_on,
                "Location: ",
                data['location'] ?? "Campus",
              ),

              _detailRow(
                Icons.category,
                "Category: ",
                data['category'] ?? "General",
              ),

              _detailRow(
                Icons.timer,
                "Time: ",

                (data['date'] != null && data['date'] is Timestamp)
                    ? DateFormat(
                        'jm',
                      ).format((data['date'] as Timestamp).toDate())
                    : "Unknown",
              ),

              const Divider(height: 30),

              const Text(
                "About Event",

                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 8),

              Text(
                data['description'] ?? 'No description available.',

                style: TextStyle(color: Colors.grey[800], height: 1.4),
              ),

              const SizedBox(height: 30),

              // REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffb1170c),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    elevation: 0,
                  ),

                  onPressed: () async {
                    try {
                      final user = FirebaseAuth.instance.currentUser;

                      await FirebaseFirestore.instance
                          .collection('eventApplications')
                          .add({
                            'eventId': eventId,
                            'eventName': data['name'],
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
                    "Register for Event",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

Future<void> _loadSavedEvents() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid == null) return;

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('saved_items')
      .where('type', isEqualTo: 'event')
      .get();

  setState(() {
    _savedEventIds.addAll(
      snapshot.docs.map((doc) => doc.id),
    );
  });
}

  Future<void> _toggleSaveEvent(
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
        _savedEventIds.remove(docId);
      });
    } else {
      await savedRef.set({
        'title': data['name'],
        'type': 'event',
        'route': '/events',
        'savedAt': Timestamp.now(),
      });

      setState(() {
        _savedEventIds.add(docId);
      });
    }
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
