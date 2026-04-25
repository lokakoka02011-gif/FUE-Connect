import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 
class VolunteerPage extends StatefulWidget {
  const VolunteerPage({super.key});

  @override
  State<VolunteerPage> createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FUE Volunteer Hub'),
      ),
      body: Column(
        children: [
          // 1. Search Section (Functional)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for opportunities...',
                prefixIcon: const Icon(Icons.volunteer_activism),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 2. Impact Areas (UI Only)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Impact Areas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Teaching', 'Environment', 'Charity', 'Events']
                  .map((area) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(area),
                          backgroundColor: Colors.red[50],
                          side: BorderSide(color: Colors.red[100]!),
                        ),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Current Opportunities",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 3. Dynamic Opportunities List from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('opportunities')
                  .where('type', isEqualTo: 'volunteering') // Filter for volunteering
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter data based on search bar
                final docs = snapshot.data!.docs.where((doc) {
                  final title = doc['title'].toString().toLowerCase();
                  return title.contains(searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No volunteer roles found"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    // Handling Date/Timestamp
                    String formattedDate = "No Deadline";
                    if (data['deadline'] != null) {
                      Timestamp timestamp = data['deadline'];
                      formattedDate = DateFormat('dd MMM yyyy').format(timestamp.toDate());
                    }

                    // Handling Int64/Int Pay or Requirements Safely
                    String payInfo = data['pay']?.toString() ?? "Unpaid";

                    return buildVolunteerCard(
                      title: data['title'] ?? 'No Title',
                      organizer: data['companyName'] ?? 'FUE Partner',
                      deadline: formattedDate,
                      isUrgent: data['isUrgent'] ?? false,
                      imageUrl: data['imageUrl'] ?? "https://via.placeholder.com/400",
                      pay: payInfo,
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

  static Widget buildVolunteerCard({
    required String title,
    required String organizer,
    required String deadline,
    required bool isUrgent,
    required String imageUrl,
    required String pay,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xffb1170c), width: 2),
      ),
      elevation: 8,
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 50),
                ),
              ),
              if (isUrgent)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "URGENT",
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "By $organizer",
                  style: const TextStyle(color: Color(0xffb1170c), fontWeight: FontWeight.w500),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(deadline, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.payments, size: 16, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(pay, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Add navigation to a details page here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffb1170c),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Apply Now", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}