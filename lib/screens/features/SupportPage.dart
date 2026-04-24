import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  // Function to trigger the email redirect
  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@fue.com',
      queryParameters: {
        'subject': 'FUE Connect Support Request',
        'body': 'Hello FUE Support Team,\n\n',
      },
    );

    try {
      // On Web, launchUrl is generally preferred with a specific mode
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(
          emailLaunchUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('Could not launch email client');
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FUE Support Center'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How can we help you?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Get in touch with the FUE Connect team or find answers below."),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Email Button with redirect logic
                _buildContactBox(
                  Icons.email, 
                  "Email Us", 
                  Colors.blue, 
                  width: 150,
                  onTap: _sendEmail,
                ),
                // Placeholder for Live Chat
                _buildContactBox(
                  Icons.chat_bubble, 
                  "Live Chat", 
                  Colors.green, 
                  width: 150,
                  onTap: () {
                    debugPrint("Live Chat Tapped");
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Emergency Button
            _buildContactBox(
              Icons.phone_in_talk, 
              "Campus Security (Emergency)", 
              Colors.red,
              width: double.infinity,
              onTap: () {
                debugPrint("Emergency Call Tapped");
              },
            ),

            const SizedBox(height: 40),
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildFAQTile("How do I join an event?",
                "Go to the Events tab, click on the event you like, and hit 'Join Event'."),
            _buildFAQTile("Where can I see my volunteer hours?",
                "You can track your approved hours in your Profile section."),
            _buildFAQTile("How to report a campus issue?",
                "Use the 'Live Chat' button above to speak with a student representative."),

            const SizedBox(height: 40),
            const Center(
              child: Text(
                "FUE Connect v1.0.0",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated helper with HitTestBehavior.opaque for Chrome compatibility
  Widget _buildContactBox(IconData icon, String label, Color color, 
      {required double width, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      // behavior: HitTestBehavior.opaque makes the entire container area clickable
      behavior: HitTestBehavior.opaque, 
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(answer, style: const TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }
}