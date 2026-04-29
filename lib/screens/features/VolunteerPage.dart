import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// Import your main.dart to access UniversalConnectCard and CategoryPill
import 'package:fue_connect/main.dart'; 

class VolunteerPage extends StatefulWidget {
  const VolunteerPage({super.key});

  @override
  State<VolunteerPage> createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  String _searchQuery = "";
  String _selectedArea = "All";
  final List<String> _impactAreas = ['All', 'Teaching', 'Environment', 'Charity', 'Events'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Volunteer Hub'),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search volunteer roles...',
                prefixIcon: const Icon(Icons.volunteer_activism, color: Color(0xffb1170c)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. IMPACT AREAS (Pills)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Impact Areas", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _impactAreas.length,
              itemBuilder: (context, index) {
                return CategoryPill(
                  label: _impactAreas[index],
                  isSelected: _selectedArea == _impactAreas[index],
                  onTap: () => setState(() => _selectedArea = _impactAreas[index]),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 3. OPPORTUNITIES LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('opportunities')
                  .where('type', isEqualTo: 'volunteering')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xffb1170c)));
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['title'] ?? "").toString().toLowerCase();
                  final area = data['impactArea'] ?? "All"; // Assuming you have an 'impactArea' field
                  
                  return title.contains(_searchQuery) && 
                         (_selectedArea == "All" || area == _selectedArea);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No volunteer roles found."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    
                    // Format deadline
                    String formattedDate = "No Deadline";
                    if (data['deadline'] != null) {
                      formattedDate = DateFormat('dd MMM yyyy').format((data['deadline'] as Timestamp).toDate());
                    }

                    return UniversalConnectCard(
                      title: data['title'] ?? 'Untitled',
                      subtitle: "By ${data['companyName'] ?? 'FUE Partner'}",
                      imageUrl: data['imageUrl'],
                      // Urgent Badge logic
                      trailing: data['isUrgent'] == true 
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                            child: const Text("URGENT", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ) 
                        : null,
                      infoRows: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text("Deadline: $formattedDate", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const Spacer(),
                            const Icon(Icons.handshake_outlined, size: 14, color: Color(0xffb1170c)),
                            const SizedBox(width: 4),
                            Text(data['impactArea'] ?? "General", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                      onTap: () => _showVolunteerDetails(context, data),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showVolunteerDetails(BuildContext context, Map<String, dynamic> data) {
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
            Text(data['title'] ?? 'Volunteer Role', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Organized by ${data['companyName'] ?? 'FUE Partner'}", style: const TextStyle(color: Color(0xffb1170c), fontWeight: FontWeight.w500)),
            const Divider(height: 30),
            _detailRow(Icons.public, "Impact Area: ", data['impactArea'] ?? "General"),
            _detailRow(Icons.payments, "Compensation: ", data['pay']?.toString() ?? "Unpaid"),
            const SizedBox(height: 20),
            const Text("About the Role", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(data['description'] ?? 'Help your community by joining this initiative!', style: TextStyle(color: Colors.grey[800], height: 1.4)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffb1170c),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                child: const Text("Apply to Volunteer", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}