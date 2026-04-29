import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// Import your main.dart to access UniversalConnectCard and CategoryPill
import 'package:fue_connect/main.dart'; 

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String _searchQuery = "";
  String _selectedCategory = "All";
  String _sortBy = "Upcoming";
  final List<String> _categories = ['All', 'Workshops', 'Sports', 'Tech', 'Music'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('FUE Events'),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CONSISTENT SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search, color: Color(0xffb1170c)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. UNIVERSAL CATEGORY PILLS
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

          // 3. SORT & HEADER ROW
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Upcoming Events", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.sort, color: Color(0xffb1170c), size: 20),
                  items: ['Upcoming', 'Popular'].map((String value) {
                    return DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(fontSize: 14)));
                  }).toList(),
                  onChanged: (val) => setState(() => _sortBy = val!),
                ),
              ],
            ),
          ),

          // 4. EVENTS LIST USING UNIVERSAL CARD
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Events').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading events"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xffb1170c)));
                }

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? "").toString().toLowerCase();
                  final category = data['category'] ?? "All";
                  
                  // Date Filtering: Hide expired events
                  DateTime eventDate = (data['date'] as Timestamp).toDate();
                  bool isExpired = eventDate.isBefore(DateTime.now().subtract(const Duration(hours: 5)));

                  return name.contains(_searchQuery) && 
                         (_selectedCategory == "All" || category == _selectedCategory) &&
                         !isExpired;
                }).toList();

                // Sorting Logic
                if (_sortBy == "Upcoming") {
                  docs.sort((a, b) => ((a['date'] as Timestamp)).compareTo(b['date'] as Timestamp));
                } else {
                  docs.sort((a, b) => (b['participants'] ?? 0).compareTo(a['participants'] ?? 0));
                }

                if (docs.isEmpty) return const Center(child: Text("No events found."));

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    DateTime dt = (data['date'] as Timestamp).toDate();
                    
                    return UniversalConnectCard(
                      title: data['name'] ?? "Event",
                      subtitle: data['description'] ?? "",
                      imageUrl: data['imageUrl'],
                      onTap: () => _showEventDetails(context, data),
                      infoRows: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 16, color: Color(0xffb1170c)),
                            const SizedBox(width: 5),
                            Text(DateFormat('MMM dd, yyyy').format(dt), 
                              style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
                            const Spacer(),
                            const Icon(Icons.people, size: 16, color: Colors.blueGrey),
                            const SizedBox(width: 4),
                            Text("${data['participants'] ?? 0} joined", 
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
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

  void _showEventDetails(BuildContext context, Map<String, dynamic> data) {
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
            Text(data['name'] ?? 'Event', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _detailRow(Icons.location_on, "Location: ", data['location'] ?? "Campus"),
            _detailRow(Icons.category, "Category: ", data['category'] ?? "General"),
            _detailRow(Icons.timer, "Time: ", DateFormat('jm').format((data['date'] as Timestamp).toDate())),
            const Divider(height: 30),
            const Text("About Event", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(data['description'] ?? 'No description available.', style: TextStyle(color: Colors.grey[800], height: 1.4)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffb1170c),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {},
                child: const Text("Register for Event", 
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xffb1170c)),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}