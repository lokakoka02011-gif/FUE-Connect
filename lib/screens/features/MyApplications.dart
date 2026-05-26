import 'package:flutter/material.dart';
import 'package:fue_connect/widgets/filter_pills.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Clubs",
    "Internships",
    "Jobs",
    "Events",
    "Volunteer",
  ];

  final List<Map<String, dynamic>> applications = [
    {
      "title": "AI Club",
      "category": "Clubs",
      "organization": "FUE",
      "date": DateTime(2026, 4, 20),
      "status": "Pending",
      "details": "Applied for AI Club membership",
    },
    {
      "title": "Frontend Intern",
      "category": "Internships",
      "organization": "Tech Co.",
      "date": DateTime(2026, 4, 18),
      "status": "Accepted",
      "details": "Frontend internship application",
    },
    {
      "title": "Volunteer Event",
      "category": "Volunteer",
      "organization": "NGO",
      "date": DateTime(2026, 4, 15),
      "status": "Declined",
      "details": "Helping in charity event",
    },
  ];

  List<Map<String, dynamic>> getFilteredApps() {
    if (selectedCategory == "All") {
      return applications;
    }

    return applications
        .where(
          (app) => app["category"] == selectedCategory,
        )
        .toList();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.green;

      case "Pending":
        return Colors.orange;

      case "Declined":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case "Internships":
        return Icons.work_outline;

      case "Jobs":
        return Icons.business_center_outlined;

      case "Clubs":
        return Icons.groups_outlined;

      case "Events":
        return Icons.event_outlined;

      case "Volunteer":
        return Icons.volunteer_activism_outlined;

      default:
        return Icons.description_outlined;
    }
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void openDetails(Map<String, dynamic> app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            children: [
              Text(
                app["title"],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                app["organization"],
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getStatusColor(
                    app["status"],
                  ).withOpacity(.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  app["status"],
                  style: TextStyle(
                    color: getStatusColor(
                      app["status"],
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                app["details"],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildApplicationCard(
    Map<String, dynamic> app,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () => openDetails(app),

        leading: CircleAvatar(
          backgroundColor:
              const Color(0xffb1170c).withOpacity(.1),
          child: Icon(
            getCategoryIcon(app["category"]),
            color: const Color(0xffb1170c),
          ),
        ),

        title: Text(
          app["title"],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          app["organization"],
        ),

        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: getStatusColor(
              app["status"],
            ).withOpacity(.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            app["status"],
            style: TextStyle(
              color: getStatusColor(
                app["status"],
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = getFilteredApps();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: const Color(0xffb1170c),
        foregroundColor: Colors.white,
        title: const Text(
          "My Applications",
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilterPills(
              options: categories,
              selected: selectedCategory,
              onSelected: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
          ),

          Expanded(
            child: filteredApps.isEmpty
                ? const Center(
                    child: Text(
                      "No applications found",
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: filteredApps.length,
                    itemBuilder: (context, index) {
                      return buildApplicationCard(
                        filteredApps[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}