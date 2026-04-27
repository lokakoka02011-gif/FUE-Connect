import 'package:flutter/material.dart';
import 'package:fue_connect/screens/features/admin/ManageItemsPage.dart';
import 'package:fue_connect/services/auth_service.dart'; // Import your auth service

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  // Function to handle logout and return to login screen
  void _handleLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut();
    // Use pushNamedAndRemoveUntil to clear the navigation stack
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // collectionKey is the actual name of your Firestore collection
    final List<Map<String, dynamic>> sections = [
      {"title": "Clubs", "icon": Icons.groups, "collectionKey": "clubs"},
      {"title": "Events", "icon": Icons.event, "collectionKey": "events"},
      {"title": "Opportunities", "icon": Icons.work, "collectionKey": "opportunities"},
      {"title": "Volunteering", "icon": Icons.volunteer_activism, "collectionKey": "volunteering"},
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
}