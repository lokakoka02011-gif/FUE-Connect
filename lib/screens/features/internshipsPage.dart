import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fue_connect/main.dart';
import 'package:fue_connect/widgets/filter_pills.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InternshipsPage extends StatefulWidget {
  const InternshipsPage({super.key});

  @override
  State<InternshipsPage> createState() => _InternshipsPageState();
}

class _InternshipsPageState extends State<InternshipsPage> {
  final Set<String> _savedOpportunityIds = {};

  String _selectedCategory = "All";

  String _searchQuery = "";

  final List<String> _categories = [
    'All',
    'Dentistry',
    'Business',
    'Tech',
    'Engineering',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Internships"),

        backgroundColor: const Color(0xffb1170c),

        foregroundColor: Colors.white,

        elevation: 0,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),

            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },

              decoration: InputDecoration(
                hintText: 'Search internships...',

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
              options: _categories,

              selected: _selectedCategory,

              onSelected: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ),

          const SizedBox(height: 5),

          Expanded(child: _buildInternshipsList()),
        ],
      ),
    );
  }

  Widget _buildInternshipsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('opportunities')
          .where('status', isEqualTo: 'approved')
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading internships"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingIndicator());
        }

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final title = (data['title'] ?? "").toString().toLowerCase();

          final typeMatch =
              data['type']?.toString().toLowerCase() == "internship";

          final categoryMatch =
              _selectedCategory == "All" ||
              data['category'] == _selectedCategory;

          return typeMatch && categoryMatch && title.contains(_searchQuery);
        }).toList();

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Icon(Icons.school_outlined, size: 50, color: Colors.grey[300]),

                const SizedBox(height: 10),

                Text(
                  "No internships found in $_selectedCategory",

                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),

          itemCount: docs.length,

          itemBuilder: (context, index) {
            final docId = docs[index].id;

            final data = docs[index].data() as Map<String, dynamic>;

            bool isSaved = _savedOpportunityIds.contains(docId);

            return UniversalConnectCard(
              title: data['title'] ?? 'Untitled',

              subtitle: data['description'] ?? '',

              imageUrl: data['imageUrl'],

              trailing: IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,

                  color: isSaved ? const Color(0xffb1170c) : Colors.grey,
                ),

                onPressed: () => _toggleSaveOpportunity(docId, data),
              ),

              infoRows: [
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_outlined,

                      size: 16,

                      color: Colors.green,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      "${data['salary'] ?? 'N/A'} EGP",

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,

                        fontSize: 13,
                      ),
                    ),

                    const Spacer(),

                    const Icon(
                      Icons.event_available,

                      size: 16,

                      color: Color(0xffb1170c),
                    ),

                    const SizedBox(width: 4),

                    Text(
                      "Deadline: ${_formatTimestamp(data['deadline'])}",

                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],

              onTap: () => _showInternshipDetails(context, docId, data),
            );
          },
        );
      },
    );
  }

  void _showInternshipDetails(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    String gpaValue = data['minimumCgpa']?.toString() ?? "N/A";

    bool showGPA = gpaValue != "N/A";

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
                data['title'] ?? 'Internship',

                style: const TextStyle(
                  fontSize: 22,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              _detailRow(
                Icons.payments,
                "Salary: ",
                "${data['salary'] ?? 'N/A'} EGP",
              ),

              if (showGPA) _detailRow(Icons.grade, "Min. CGPA: ", gpaValue),

              _detailRow(
                Icons.calendar_today,
                "Deadline: ",
                _formatTimestamp(data['deadline']),
              ),

              const Divider(height: 30),

              const Text(
                "Description",

                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 8),

              Text(
                data['description'] ?? 'No description provided.',

                style: TextStyle(color: Colors.grey[800], height: 1.4),
              ),

              const SizedBox(height: 20),

              const Text(
                "Requirements",

                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 8),

              Text(
                data['requirements'] ?? 'Standard eligibility.',

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

                    if ((userData['cvUrl'] ?? '').toString().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please upload your CV before applying.",
                          ),
                        ),
                      );

                      return;
                    }

                    final confirm = await showDialog<bool>(
                      context: context,

                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Confirm Application"),

                          content: const Text(
                            "You are applying for this internship.\n\n"
                            "FUE Connect will share your profile information, "
                            "CV, skills, GPA, and contact details with this company "
                            "for recruitment purposes.\n\n"
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

                    final existingApplication = await FirebaseFirestore.instance
                        .collection('applications')
                        .where('studentId', isEqualTo: user.uid)
                        .where('opportunityId', isEqualTo: docId)
                        .get();

                    if (existingApplication.docs.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "You already applied for this internship.",
                          ),
                        ),
                      );

                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection('applications')
                        .add({
                          "studentId": user.uid,

                          "companyId": data['createdBy'] ?? "",

                          "opportunityId": docId,

                          "applicationStatus": "pending",

                          "appliedAt": Timestamp.now(),

                          "studentName": userData['fullName'] ?? "",

                          "studentEmail": userData['email'] ?? "",

                          "studentPhone": userData['phone'] ?? "",

                          "faculty": userData['faculty'] ?? "",

                          "major": userData['major'] ?? "",

                          "gpa": userData['gpa'] ?? "",

                          "skills": userData['skills'] ?? [],

                          "cvUrl": userData['cvUrl'] ?? "",

                          "profileImage": userData['profileImage'] ?? "",

                          "opportunityTitle": data['title'] ?? "",

                          "opportunityType": data['type'] ?? "",

                          "companyName": data['companyName'] ?? "",
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
                    "Apply Now",

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

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xffb1170c)),

          const SizedBox(width: 10),

          Text(label, style: const TextStyle(color: Colors.grey)),

          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _toggleSaveOpportunity(
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
        _savedOpportunityIds.remove(docId);
      });
    } else {
      await savedRef.set({
        'title': data['title'],
        'type': data['type'],
        'imageUrl': data['imageUrl'],
        'route': '/internships',
        'savedAt': Timestamp.now(),
      });

      setState(() {
        _savedOpportunityIds.add(docId);
      });
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';

    if (timestamp is Timestamp) {
      return DateFormat('dd MMM yyyy').format(timestamp.toDate());
    }

    return timestamp.toString();
  }
}
