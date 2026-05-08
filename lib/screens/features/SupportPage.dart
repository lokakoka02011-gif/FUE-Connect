import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  final Color fueRed = const Color(0xffb1170c);

  // function beteftah links
  Future<void> _launchUrl(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Error launching: $e');
    }
  }

  // send email to support (redirect)
  Future<void> _sendEmail() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: 'support@fue.edu.eg',
      queryParameters: {'subject': 'FUE Connect Support Request'},
    );
    await _launchUrl(uri);
  }

  // Phone call 
  Future<void> _makeCall() async {
    final Uri uri = Uri(scheme: 'tel', path: '+2012345678'); 
    await _launchUrl(uri);
  }

  // Social media links
  Future<void> _launchSocial(String platform) async {
    final String url = platform == 'instagram' 
      ? 'https://www.instagram.com/fue_egypt' 
      : 'https://www.facebook.com/fue.edu.eg';
    await _launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('FUE Support Center'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
              children: [
                Expanded(
                  child: _buildContactBox(
                    context,
                    Icons.email_rounded,
                    "Email Us",
                    Colors.blue,
                    onTap: _sendEmail,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildContactBox(
                    context,
                    Icons.forum_rounded, 
                    "Live Chat",
                    Colors.green,
                    onTap: () {
                      debugPrint("Live Chat Clicked");
                      Navigator.pushNamed(context, '/chat');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            _buildContactBox(
              context,
              Icons.phone_in_talk_rounded,
              "Campus Security (Emergency)",
              fueRed,
              isFullWidth: true,
              onTap: _makeCall,
            ),

            const SizedBox(height: 40),
            const Text("Follow FUE Official", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            Row(
              children: [
                // instagram Button
                _buildSocialIconButton(
                  icon: Icons.camera_alt_rounded,
                  color: Colors.purple, 
                  onPressed: () => _launchSocial('instagram'),
                ),
                const SizedBox(width: 15),
                // Facebook Button
                _buildSocialIconButton(
                  icon: Icons.facebook_rounded,
                  color: const Color(0xFF1877F2), 
                  onPressed: () => _launchSocial('facebook'),
                ),
              ],
            ),

            const SizedBox(height: 40),
            // FAQs
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildFAQTile("How do I join an event?",
                "Go to the Events tab, click on the event you like, and hit 'Join Event'."),
            _buildFAQTile("Is there a minimum GPA for opportunities?",
                "Some professional opportunities require a specific GPA. Check the 'Recommended' section for details tailored to your profile."),
            _buildFAQTile("How can I update my Major/Minor?",
                "You can edit your academic info in the Account section (coming soon)."),
            _buildFAQTile("Where is the student clinic located?",
                "The main clinic is located in the Ground Floor of the Dental Hospital building."),
            _buildFAQTile("Forgotten ID or Password?",
                "Use the 'Forgot Password' link on the Login screen to receive a reset link at your FUE email."),

            const SizedBox(height: 50),
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

// build social button
  Widget _buildSocialIconButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }

// build contact box (clickable)
  Widget _buildContactBox(BuildContext context, IconData icon, String label, Color color,
      {bool isFullWidth = false, required VoidCallback onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          highlightColor: color.withOpacity(0.05),
          splashColor: color.withOpacity(0.1),
          child: Container(
            width: isFullWidth ? double.infinity : null,
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer, style: const TextStyle(color: Colors.black87, height: 1.4)),
        ),
      ],
    );
  }
}