import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// Import your main.dart to access UniversalConnectCard and CategoryPill
import 'package:fue_connect/main.dart'; 

class OpportunitiesPage extends StatefulWidget {
  const OpportunitiesPage({super.key});

  @override
  State<OpportunitiesPage> createState() => _OpportunitiesPageState();
}

class _OpportunitiesPageState extends State<OpportunitiesPage> {
  final Set<String> _savedOpportunityIds = {};
  String _selectedCategory = "All";
  
  // Example categories - adjust based on your Firestore fields
  final List<String> _categories = ['All', 'Tech', 'Business', 'Design', 'Engineering'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Opportunities"),
          backgroundColor: const Color(0xffb1170c),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Internships", icon: Icon(Icons.school_outlined, size: 20)),
              Tab(text: "Jobs", icon: Icon(Icons.work_outline, size: 20)),
            ],
          ),
        ),
        body: Column(
          children: [
            // 1. CATEGORY PILLS (Placed below the TabBar)
            const SizedBox(height: 15),
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return CategoryPill(
                    label: _categories[index],
                    isSelected: _selectedCategory == _categories[index],
                    onTap: () => setState(() => _selectedCategory = _categories[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 5),

            // 2. TAB CONTENT
            Expanded(
              child: TabBarView(
                children: [
                  _buildOpportunityList("internship"),
                  _buildOpportunityList("job"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunityList(String filterType) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Opportunity').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Error loading data"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xffb1170c)));
        }

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final typeMatch = data['Type']?.toString().toLowerCase() == filterType;
          final categoryMatch = _selectedCategory == "All" || 
                               (data['Category']?.toString() == _selectedCategory);
          return typeMatch && categoryMatch;
        }).toList();

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_off_outlined, size: 50, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text("No $filterType found in $_selectedCategory", 
                     style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final docId = docs[index].id;
            final data = docs[index].data() as Map<String, dynamic>;
            bool isSaved = _savedOpportunityIds.contains(docId);

            return UniversalConnectCard(
              title: data['Title'] ?? 'Untitled',
              subtitle: data['Description'] ?? '',
              // Using a default job/internship icon if no image exists
              imageUrl: data['imageUrl'], 
              trailing: IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? const Color(0xffb1170c) : Colors.grey,
                ),
                onPressed: () => _toggleSaveOpportunity(docId),
              ),
              infoRows: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on_outlined, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text("${data['Pay'] ?? 'N/A'} EGP", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Spacer(),
                    const Icon(Icons.event_available, size: 16, color: Color(0xffb1170c)),
                    const SizedBox(width: 4),
                    Text("Deadline: ${_formatTimestamp(data['Deadline'])}", 
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
              onTap: () => _showOpportunityDetails(context, docId, data),
            );
          },
        );
      },
    );
  }

  void _showOpportunityDetails(BuildContext context, String docId, Map<String, dynamic> data) {
    String gpaValue = data['GPA']?.toString() ?? "NA";
    bool showGPA = gpaValue.toUpperCase() != "NA";

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
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text(data['Title'] ?? 'Opportunity', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _detailRow(Icons.payments, "Salary: ", "${data['Pay'] ?? 'N/A'} EGP"),
            if (showGPA) _detailRow(Icons.grade, "Min. GPA: ", gpaValue),
            _detailRow(Icons.calendar_today, "Deadline: ", _formatTimestamp(data['Deadline'])),
            const Divider(height: 30),
            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(data['Description'] ?? 'No description provided.', style: TextStyle(color: Colors.grey[800], height: 1.4)),
            const SizedBox(height: 20),
            const Text("Requirements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(data['Requirments'] ?? 'Standard eligibility.', style: TextStyle(color: Colors.grey[800], height: 1.4)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffb1170c),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context, 
                    '/forms',
                    arguments: data,
                    );
                },
                child: const Text("Apply Now", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xffb1170c)),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _toggleSaveOpportunity(String docId) {
    setState(() {
      if (_savedOpportunityIds.contains(docId)) {
        _savedOpportunityIds.remove(docId);
      } else {
        _savedOpportunityIds.add(docId);
      }
    });
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      return DateFormat('dd MMM yyyy').format(timestamp.toDate());
    }
    return timestamp.toString();
  }
}