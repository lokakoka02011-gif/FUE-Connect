import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OpportunitiesPage extends StatelessWidget {
  const OpportunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Opportunities"),
          bottom: const TabBar(
            // --- UPDATED TAB COLORS ---
            labelColor: Colors.white, // Active icon and text
            unselectedLabelColor: Colors.white70, // High-contrast grey-white for inactive
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Internships", icon: Icon(Icons.school_outlined)),
              Tab(text: "Jobs", icon: Icon(Icons.work_outline)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOpportunityList("internship"),
            _buildOpportunityList("job"),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunityList(String filterType) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Opportunity').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading opportunities"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xffb1170c)));
        }

        // Filtering logic: Check 'Type' field against 'job' or 'internship'
        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null || !data.containsKey('Type')) return false;

          final typeField = data['Type'].toString().toLowerCase();
          return typeField == filterType;
        }).toList();

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text("No $filterType available right now",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                title: Text(
                  (data['Title'] ?? 'Untitled').toString(),
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      (data['Description'] ?? '').toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.money, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          "Salary: ${(data['Pay'] ?? 'N/A')} EGP",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        const Icon(Icons.timer_outlined,
                            size: 16, color: Color(0xffb1170c)),
                        const SizedBox(width: 4),
                        Text(
                          "Until: ${_formatTimestamp(data['Deadline'])}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () => _showOpportunityDetails(context, data),
              ),
            );
          },
        );
      },
    );
  }

  void _showOpportunityDetails(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Text((data['Title'] ?? 'Opportunity').toString(),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _detailRow(Icons.payments, "Salary: ",
                "${(data['Pay'] ?? 'N/A')} EGP"),
            _detailRow(Icons.person, "Staff: ",
                (data['staffRef'] ?? 'N/A').toString()),
            _detailRow(Icons.calendar_today, "Deadline: ", 
                _formatTimestamp(data['Deadline'])),
            const Divider(height: 30),
            const Text("Description",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text((data['Description'] ?? 'No description provided.').toString()),
            const SizedBox(height: 20),
            const Text("Requirements",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text((data['Requirments'] ?? 'No specific requirements.').toString()),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffb1170c),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Link application logic here
                },
                child: const Text("Apply for this Opportunity",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // HELPER: Formats Firestore Timestamp to readable DD/MM/YYYY
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return "${date.day}/${date.month}/${date.year}";
    }
    return timestamp.toString();
  }
}