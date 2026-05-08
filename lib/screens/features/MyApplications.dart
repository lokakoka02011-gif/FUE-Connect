import 'package:flutter/material.dart';

void main() {
  runApp(const FUEConnectApp());
}

class FUEConnectApp extends StatelessWidget {
  const FUEConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FUE Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyApplicationsPage(),
    );
  }
}

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

// filter applications by selected category (All returns everything)
  List<Map<String, dynamic>> getFilteredApps(String category) {
    if (category == "All") return applications;
    return applications.where((app) => app["category"] == category).toList();
  }

// map application status returns UI color
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

// show full application details in dialog
  void openDetails(Map<String, dynamic> app) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(app["title"]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Organization: ${app["organization"]}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Date: ${_formatDate(app["date"])}"),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Status: "),
                Text(app["status"],
                    style: TextStyle(
                        color: getStatusColor(app["status"]),
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            Text(app["details"]),
          ],
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

// format date to readable string 
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Applications",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
            // tabs to switch between application categories
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) {
          final filteredApps = getFilteredApps(category);

          if (filteredApps.isEmpty) {
            return const Center(
              child: Text("No applications found",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: filteredApps.length,
            itemBuilder: (context, index) {
              final app = filteredApps[index];

              return Card(
                elevation: 0.5,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => openDetails(app),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                app["title"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: getStatusColor(app["status"])
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                app["status"].toUpperCase(),
                                style: TextStyle(
                                  color: getStatusColor(app["status"]),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          app["organization"],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_month_outlined,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(app["date"]),
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
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