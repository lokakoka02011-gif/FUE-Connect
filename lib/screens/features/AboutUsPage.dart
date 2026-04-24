import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  // Function to launch external URLs
  Future<void> _launchURL(String url) async {
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
                    "FUE Connect is a graduation project designed to solve the fragmentation of university communication. By integrating Firebase with Flutter, we created a high-performance hub for Management Information Systems students and the wider FUE community.",
                    style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),

            const Divider(height: 10, indent: 30, endIndent: 30),

            // 3. Team Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("The Team", 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: fueRed)),
                  const SizedBox(height: 16),
                  
                  // Team Leader (You)
                  _buildTeamMember(
                    "Mel", 
                    "Project Leader & Lead Developer", 
                    isLeader: true,
                    linkedin: "https://www.google.com",
                    cv: "https://www.google.com"
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Team Members
                  _buildTeamMember("Team Member 2", "UI/UX Designer", linkedin: "https://google.com", cv: "https://google.com"),
                  _buildTeamMember("Team Member 3", "Backend Specialist", linkedin: "https://google.com", cv: "https://google.com"),
                  _buildTeamMember("Team Member 4", "Database Admin", linkedin: "https://google.com", cv: "https://google.com"),
                  _buildTeamMember("Team Member 5", "Marketing Analyst", linkedin: "https://google.com", cv: "https://google.com"),
                  _buildTeamMember("Team Member 6", "QA & Testing", linkedin: "https://google.com", cv: "https://google.com"),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(String name, String role, {bool isLeader = false, required String linkedin, required String cv}) {
    return Card(
      elevation: isLeader ? 4 : 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLeader ? const BorderSide(color: Color(0xffb1170c), width: 1.5) : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLeader ? const Color(0xffb1170c) : Colors.grey[300],
          child: Icon(Icons.person, color: isLeader ? Colors.white : Colors.grey[600]),
        ),
        title: Text(name, style: TextStyle(fontWeight: isLeader ? FontWeight.bold : FontWeight.normal)),
        subtitle: Text(role, style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.link, color: Colors.blue, size: 20),
              onPressed: () => _launchURL(linkedin),
              tooltip: "LinkedIn",
            ),
            IconButton(
              icon: const Icon(Icons.description_outlined, color: Colors.orange, size: 20),
              onPressed: () => _launchURL(cv),
              tooltip: "View CV",
            ),
          ],
        ),
      ),
    );
  }
}