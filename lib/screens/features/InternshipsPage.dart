import 'package:flutter/material.dart';

class InternshipsPage extends StatelessWidget {
  const InternshipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Internships')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Standardized Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search roles...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            _buildInternshipCard(
              title: "Frontend Developer Intern",
              company: "Tech Solutions",
              location: "Cairo",
              imageUrl: "assets/images/frontend.png",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInternshipCard({
    required String title,
    required String company,
    required String location,
    required String imageUrl,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // ✅ match other pages
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(
          color: Color(0xffb1170c), 
          width: 2,
        ),
      ),
      elevation: 8, // ✅ match "featured" feel
      child: Column(
        children: [
         ClipRRect(
  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
  child: Image.asset(
    imageUrl,
    height: 130,
    width: double.infinity,
    fit: BoxFit.cover,
  ),
),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "$company • $location",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffb1170c),
                    ),
                    child: const Text(
                      "Apply Now",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}