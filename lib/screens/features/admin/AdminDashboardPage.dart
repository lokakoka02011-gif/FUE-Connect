import 'package:flutter/material.dart';
import 'package:fue_connect/screens/features/admin/ManageItemsPage.dart';
import 'package:fue_connect/services/auth_service.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {  
  // Removed totalUsers, totalApplications, totalOpportunities, and fetchStats logic

  void _handleLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Note: Ensure collectionKey matches your Firestore exactly (case-sensitive)
    final List<Map<String, dynamic>> sections = [
      {"title": "Clubs", "icon": Icons.groups, "collectionKey": "Clubs"},
      {"title": "Events", "icon": Icons.event, "collectionKey": "Events"},
      {"title": "Opportunities", "icon": Icons.work, "collectionKey": "Opportunity"},
      {"title": "Volunteering", "icon": Icons.volunteer_activism, "collectionKey": "volunteering"}, // Fixed key case
    ];

    const Color fueRed = Color(0xffb1170c);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Admin Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: fueRed,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout Admin',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Management Portal",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          
          // Counters section has been removed from here

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sections.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final section = sections[index];
                // Fallback for empty titles
                final String displayTitle = (section["title"] == null || section["title"].isEmpty) 
                    ? "Unnamed Section" 
                    : section["title"];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManageItemsPage(
                          title: displayTitle,
                          collectionPath: section["collectionKey"] ?? "unknown",
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    shadowColor: Colors.black26,
                    color:fueRed,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration:const  BoxDecoration(
                            color: Colors.white, // Fixed: Red background
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            section["icon"], 
                            size: 40, 
                            color: Colors.red // Fixed: White icon
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          displayTitle,
                          style: const TextStyle(
                            color: Colors.white,
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Manage Data",
                          style: TextStyle(fontSize: 12, color: Colors.white,)
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}