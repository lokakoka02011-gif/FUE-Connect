import 'package:flutter/material.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> categories = [
    "All",
    "Clubs",
    "Internships",
    "Jobs",
    "Events",
    "Volunteer"
  ];

  // 🔥 Improved dummy data with IDs + DateTime
  List<Map<String, dynamic>> applications = [
    {
      "id": "1",
      "title": "AI Club",
      "category": "Clubs",
      "organization": "FUE",
      "date": DateTime(2026, 4, 20),
      "status": "Pending",
      "details": "Applied for AI Club membership"
    },
    {
      "id": "2",
      "title": "Frontend Intern",
      "category": "Internships",
      "organization": "Tech Co.",
      "date": DateTime(2026, 4, 18),
      "status": "Accepted",
      "details": "Frontend internship application"
    },
    {
      "id": "3",
      "title": "Volunteer Event",
      "category": "Volunteer",
      "organization": "NGO",
      "date": DateTime(2026, 4, 15),
      "status": "Declined",
      "details": "Helping in charity event"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  // ---------------- FILTER ----------------
  List<Map<String, dynamic>> getFilteredApps(String category) {
    if (category == "All") return applications;
    return applications
        .where((app) => app["category"] == category)
        .toList();
  }

  // ---------------- STATUS COLOR ----------------
  Color getStatusColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.green;
      case "Declined":
        return Colors.red;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // ---------------- WITHDRAW ----------------
  void withdrawApplication(String id) {
    setState(() {
      applications.removeWhere((app) => app["id"] == id);
    });
  }

  // ---------------- DETAILS ----------------
  void openDetails(Map<String, dynamic> app) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(app["title"]),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Organization: ${app["organization"]}"),
              Text("Date: ${_formatDate(app["date"])}"),
              Text("Status: ${app["status"]}"),
              const SizedBox(height: 10),
              Text(app["details"]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Applications"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) {
          final filteredApps = getFilteredApps(category);

          if (filteredApps.isEmpty) {
            return const Center(
              child: Text("No applications found"),
            );
          }

          return ListView.builder(
            itemCount: filteredApps.length,
            itemBuilder: (context, index) {
              final app = filteredApps[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  onTap: () => openDetails(app),
                  title: Text(
                    app["title"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "${app["organization"]} • ${_formatDate(app["date"])}"),
                      const SizedBox(height: 6),

                      // 🔥 STATUS CHIP
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStatusColor(app["status"])
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          app["status"],
                          style: TextStyle(
                            color: getStatusColor(app["status"]),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => withdrawApplication(app["id"]),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}