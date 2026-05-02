import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  // Function to launch external URLs (LinkedIn/CV)
  Future<void> _launchURL(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color fueRed = Color(0xffb1170c);

    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: fueRed,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: fueRed.withOpacity(0.05),
                border: const Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.hub_rounded, size: 80, color: fueRed),
                  const SizedBox(height: 16),
                  const Text(
                    "FUE Connect",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: fueRed),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Centralizing Student Life & Opportunities",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700], fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

            // 2. Mission Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("The Project", 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: fueRed)),
                  const SizedBox(height: 12),
                  Text(
                    "FUE Connect is a graduation project designed to solve the fragmentation of university communication. By integrating Firebase with Flutter, we created a high-performance hub for the FUE community.",
                    style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),

            const Divider(height: 10, indent: 30, endIndent: 30),

            // 3. Dynamic Team Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Meet The Team", 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: fueRed)),
                  const SizedBox(height: 16),
                  
                  StreamBuilder<QuerySnapshot>(
                    // Query Firestore where isTeamMember field is true
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('isTeamMember', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Text("Error loading team.");
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final teamDocs = snapshot.data!.docs;

                      if (teamDocs.isEmpty) {
                        return const Text("No team members found in database.");
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: teamDocs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          var data = teamDocs[index].data() as Map<String, dynamic>;
                          
                          // Displaying data using 'teamRole' and 'description'
                          return _buildTeamMember(
                            "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}",
                            data['teamRole'] ?? "Team Member", // Changed from 'role' to 'teamRole'
                            description: data['description'] ?? "No bio available.",
                            linkedin: data['linkedin'] ?? "",
                            cv: data['cv'] ?? "",
                            // Highlight if the role contains 'Leader'
                            isLeader: data['teamRole']?.toString().toLowerCase().contains('leader') ?? false,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(String name, String role, 
      {bool isLeader = false, required String description, required String linkedin, required String cv}) {
    return Card(
      elevation: isLeader ? 4 : 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLeader ? const BorderSide(color: Color(0xffb1170c), width: 1.5) : BorderSide.none,
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isLeader ? const Color(0xffb1170c) : Colors.grey[300],
          child: Icon(Icons.person, color: isLeader ? Colors.white : Colors.grey[600]),
        ),
        title: Text(name, style: TextStyle(fontWeight: isLeader ? FontWeight.bold : FontWeight.normal)),
        subtitle: Text(role, style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (linkedin.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.link, color: Colors.blue, size: 20),
                onPressed: () => _launchURL(linkedin),
              ),
            if (cv.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.description_outlined, color: Colors.orange, size: 20),
                onPressed: () => _launchURL(cv),
              ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              description,
              style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}