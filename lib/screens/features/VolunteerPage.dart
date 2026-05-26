import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:fue_connect/main.dart';
import 'package:fue_connect/widgets/filter_pills.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VolunteerPage extends StatefulWidget {
  const VolunteerPage({super.key});

  @override
  State<VolunteerPage> createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  final Set<String> _savedVolunteerIds = {};
  String _searchQuery = "";
  String _selectedArea = "All";
  final List<String> _impactAreas = [
    'All',
    'Teaching',
    'Environment',
    'Charity',
    'Events',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Volunteer Hub'), elevation: 0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search volunteer roles...',
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilterPills(
              options: _impactAreas,
              selected: _selectedArea,
              onSelected: (value) {
                setState(() {
                  _selectedArea = value;
                });
              },
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('volunteering')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text("Something went wrong"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['title'] ?? "").toString().toLowerCase();
                  final area = data['impactArea'] ?? "All";

                  return title.contains(_searchQuery) &&
                      (_selectedArea == "All" || area == _selectedArea);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No volunteer roles found."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    bool isSaved = _savedVolunteerIds.contains(docId);

                    // Formating el deadline date
                    String formattedDate = "No Deadline";
                    if (data['deadline'] != null) {
                      formattedDate = DateFormat(
                        'dd MMM yyyy',
                      ).format((data['deadline'] as Timestamp).toDate());
                    }

                    return UniversalConnectCard(
                      title: data['title'] ?? 'Untitled',
                      subtitle: "By ${data['companyName'] ?? 'FUE Partner'}",
                      imageUrl: data['imageUrl'],

                      trailing: IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved
                              ? const Color(0xffb1170c)
                              : Colors.grey,
                        ),
                        onPressed: () => _toggleSaveVolunteer(docId, data),
                      ),

                      infoRows: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Deadline: $formattedDate",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.handshake_outlined,
                              size: 14,
                              color: Color(0xffb1170c),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              data['impactArea'] ?? "General",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                      onTap: () => _showVolunteerDetails(context, data),
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

  // show details popup lel volunteer
  void _showVolunteerDetails(BuildContext context, Map<String, dynamic> data) {
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
                data['title'] ?? 'Volunteer Role',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Organized by ${data['companyName'] ?? 'FUE Partner'}",
                style: const TextStyle(
                  color: Color(0xffb1170c),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Divider(height: 30),
              _detailRow(
                Icons.public,
                "Impact Area: ",
                data['impactArea'] ?? "General",
              ),
              _detailRow(
                Icons.payments,
                "Compensation: ",
                data['pay']?.toString() ?? "Unpaid",
              ),
              const SizedBox(height: 20),
              const Text(
                "About the Role",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                data['description'] ??
                    'Help your community by joining this initiative!',
                style: TextStyle(color: Colors.grey[800], height: 1.4),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffb1170c),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user == null) return;

                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();

                    final userData = userDoc.data();

                    if (userData == null) return;

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Confirm Application"),

                          content: const Text(
                            "You are applying for this volunteering opportunity.\n\n"
                            "Your profile information will be shared "
                            "with the organization.\n\n"
                            "Do you want to continue?",
                          ),

                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffb1170c),
                              ),

                              onPressed: () => Navigator.pop(context, true),

                              child: const Text(
                                "Apply",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm != true) return;

                    await FirebaseFirestore.instance
                        .collection('volunteer_applications')
                        .add({
                          "studentId": user.uid,

                          "studentName": userData['fullName'] ?? "",

                          "studentEmail": userData['email'] ?? "",

                          "studentPhone": userData['phone'] ?? "",

                          "faculty": userData['faculty'] ?? "",

                          "major": userData['major'] ?? "",

                          "gpa": userData['gpa'] ?? "",

                          "skills": userData['skills'] ?? [],

                          "profileImage": userData['profileImage'] ?? "",

                          "volunteerTitle": data['title'] ?? "",

                          "organization": data['companyName'] ?? "",

                          "applicationStatus": "pending",

                          "appliedAt": Timestamp.now(),
                        });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text("Application submitted successfully."),
                      ),
                    );
                  },
                  child: const Text(
                    "Apply to Volunteer",
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

  Future<void> _toggleSaveVolunteer(
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
        _savedVolunteerIds.remove(docId);
      });
    } else {
      await savedRef.set({
        'title': data['title'],
        'type': 'Volunteer',
        'imageUrl': data['imageUrl'],
        'route': '/volunteer',
        'savedAt': Timestamp.now(),
      });

      setState(() {
        _savedVolunteerIds.add(docId);
      });
    }
  }

  // row feh icon + label + value
  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
