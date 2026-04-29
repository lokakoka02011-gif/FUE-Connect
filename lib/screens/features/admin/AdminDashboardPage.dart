import 'package:flutter/material.dart';
import 'package:fue_connect/screens/features/admin/ManageItemsPage.dart';
import 'package:fue_connect/services/auth_service.dart'; // Import your auth service
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {  
  int totalUsers = 0;
  int totalApplications = 0;
  int totalOpportunities = 0;

  bool isLoading = true;
  Future<void> fetchStats() async {
    final users = await FirebaseFirestore.instance.collection('users').get();
    final applications = await FirebaseFirestore.instance.collection('applications').get();
    final opportunities = await FirebaseFirestore.instance.collection('opportunities').get();

    setState(() {
      totalUsers = users.docs.length;
      totalApplications = applications.docs.length;
      totalOpportunities = opportunities.docs.length;
      isLoading = false;
    });
  }
  void _handleLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut();
    // Use pushNamedAndRemoveUntil to clear the navigation stack
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  void initState() {
  super.initState();
  fetchStats();
  }
  @override
  Widget build(BuildContext context) {
    // collectionKey is the actual name of your Firestore collection
    final List<Map<String, dynamic>> sections = [
      {"title": "Clubs", "icon": Icons.groups, "collectionKey": "Clubs"},
      {"title": "Events", "icon": Icons.event, "collectionKey": "Events"},
      {"title": "Opportunities", "icon": Icons.work, "collectionKey": "Opportunity"},
      {"title": "Volunteering", "icon": Icons.volunteer_activism, "collectionKey": "Volunteering"},
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
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard("Users", totalUsers),
                      _buildStatCard("Applications", totalApplications),
                      _buildStatCard("Opportunities", totalOpportunities),
                    ],
                  ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sections.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1, // Adjusts the height of the cards
              ),
              itemBuilder: (context, index) {
                final section = sections[index];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManageItemsPage(
                          title: section["title"],
                          collectionPath: section["collectionKey"], // Logic passed here
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    shadowColor: Colors.black26,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: fueRed.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(section["icon"], size: 40, color: fueRed),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          section["title"],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Manage Data",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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
  Widget _buildStatCard(String title, int value) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 5),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffb1170c),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }  
}
