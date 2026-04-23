import 'package:flutter/material.dart';

class VolunteerPage extends StatelessWidget {
  const VolunteerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FUE Volunteer Hub'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search & Filter Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for opportunities...',
                  prefixIcon: const Icon(Icons.volunteer_activism),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Volunteer Categories
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Impact Areas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  'All',
                  'Teaching',
                  'Environment',
                  'Charity',
                  'Events'
                ].map((area) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text(area),
                      backgroundColor: Colors.red[50],
                      side: BorderSide(color: Colors.red[100]!),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Opportunities List
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Current Opportunities",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            buildVolunteerCard(
              title: "Campus Green Initiative",
              organizer: "FUE Sustainability Club",
              hours: "5 Hours/Week",
              isUrgent: true,
              imageUrl:
                  "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?q=80&w=400",
            ),

            buildVolunteerCard(
              title: "Peer Tutoring - Math",
              organizer: "FUE Student Union",
              hours: "Flexible",
              isUrgent: false,
              imageUrl:
                  "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&w=400",
            ),

            buildVolunteerCard(
              title: "Food Drive Logistics",
              organizer: "Egyptian Red Crescent",
              hours: "Weekend only",
              isUrgent: false,
              imageUrl:
                  "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=400",
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildVolunteerCard({
    required String title,
    required String organizer,
    required String hours,
    required bool isUrgent,
    required String imageUrl,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // ✅ consistent spacing
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(
          color: Color(0xffb1170c), // 🔴 SAME RED BORDER
          width: 2,
        ),
      ),
      elevation: 8, // ✅ match other pages
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (isUrgent)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "URGENT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "By $organizer",
                  style: const TextStyle(
                    color: Color(0xffb1170c),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          hours,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffb1170c),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Apply Now",
                        style: TextStyle(color: Colors.white),
                      ),
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