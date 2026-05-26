import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "FUE Connect Terms & Conditions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            Text(
              "1. Acceptance of Terms",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "By creating an account and using FUE Connect, you agree to comply with these Terms & Conditions and all applicable university policies.",
            ),

            SizedBox(height: 16),

            Text(
              "2. User Eligibility",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "Users must provide accurate and complete information during registration. Students should use valid university credentials where applicable.",
            ),

            SizedBox(height: 16),

            Text(
              "3. User Responsibilities",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "Users are responsible for maintaining the confidentiality of their accounts and for all activities performed under their accounts. Any misuse of the platform may result in account suspension.",
            ),

            SizedBox(height: 16),

            Text(
              "4. Opportunities and Content",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "FUE Connect provides internships, jobs, volunteering opportunities, events, clubs, and university announcements. Users must not submit false, misleading, offensive, or unauthorized content.",
            ),

            SizedBox(height: 16),

            Text(
              "5. Privacy",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "Personal information is collected and used to provide platform services, manage applications, recommend opportunities, communicate updates, and improve user experience. Information is handled in accordance with applicable privacy requirements.",
            ),

            SizedBox(height: 16),

            Text(
              "6. Data Sharing with Employers and Organizations",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "By applying to internships, jobs, volunteering opportunities, events, or club activities through FUE Connect, users consent to sharing relevant profile information with the organization providing the opportunity. Shared information may include the student's name, email address, academic information, uploaded CV, skills, and any additional information voluntarily submitted during the application process. FUE Connect only shares information necessary to process applications and participation requests.",
            ),

            SizedBox(height: 16),

            Text(
              "7. Prohibited Activities",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "Users may not misuse the platform, upload harmful content, impersonate others, attempt unauthorized access to system resources, distribute spam, or engage in any activity that disrupts platform operations.",
            ),

            SizedBox(height: 16),

            Text(
              "8. Account Suspension",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "FUE Connect reserves the right to suspend, restrict, or remove accounts that violate these Terms & Conditions, provide false information, or misuse platform services.",
            ),

            SizedBox(height: 16),

            Text(
              "9. Limitation of Liability",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "FUE Connect is not responsible for decisions made by external companies, organizations, clubs, or event providers regarding applications, selections, interviews, internships, jobs, volunteering opportunities, or event participation.",
            ),

            SizedBox(height: 16),

            Text(
              "10. Changes to Terms",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "These Terms & Conditions may be updated periodically. Continued use of the platform after updates constitutes acceptance of the revised Terms & Conditions.",
            ),

            SizedBox(height: 30),

            Center(
              child: Text(
                "Last Updated: May 2026",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
