import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String _searchQuery = "";
  String _selectedCategory = "All";
  String _sortBy = "Upcoming"; // Default sort

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FUE Connect Events')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // 2. Category & Sort Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.sort, color: Color(0xffb1170c)),
                  items: ['Upcoming', 'Popular'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() => _sortBy = newValue!);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Workshops', 'Sports', 'Tech', 'Music'].map((cat) {
                bool isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xffb1170c),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    onSelected: (bool selected) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Live Events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Events').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading events"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filtering and Sorting Logic
                List<QueryDocumentSnapshot> docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? "").toString().toLowerCase();
                  final category = data['category'] ?? "All";
                  
                  // Hide if event date is in the past
                  DateTime eventDate = DateTime.now();
                  if (data['date'] is Timestamp) {
                    eventDate = (data['date'] as Timestamp).toDate();
                  }
                  bool isExpired = eventDate.isBefore(DateTime.now());

                  bool matchesSearch = name.contains(_searchQuery);
                  bool matchesCategory = _selectedCategory == "All" || category == _selectedCategory;

                  return matchesSearch && matchesCategory && !isExpired; // Point 2: Disappear if ended
                }).toList();

                // Point 3: Sorting logic
                if (_sortBy == "Upcoming") {
                  docs.sort((a, b) {
                    var d1 = (a.data() as Map<String, dynamic>)['date'] as Timestamp;
                    var d2 = (b.data() as Map<String, dynamic>)['date'] as Timestamp;
                    return d1.compareTo(d2);
                  });
                } else if (_sortBy == "Popular") {
                  docs.sort((a, b) {
                    var p1 = (a.data() as Map<String, dynamic>)['participants'] ?? 0;
                    var p2 = (b.data() as Map<String, dynamic>)['participants'] ?? 0;
                    return p2.compareTo(p1);
                  });
                }

                if (docs.isEmpty) return const Center(child: Text("No upcoming events found."));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    DateTime eventDateTime = DateTime.now();
                    if (data['date'] is Timestamp) {
                      eventDateTime = (data['date'] as Timestamp).toDate();
                    }
                    
                    String displayDate = "${eventDateTime.day}/${eventDateTime.month}/${eventDateTime.year}";
                    bool hasEnded = eventDateTime.isBefore(DateTime.now());

                    return _buildEventCard(
                      title: data['name'] ?? "Event Name",
                      date: displayDate,
                      location: data['location'] ?? "FUE Campus",
                      imageUrl: data['imageUrl'] ?? "https://via.placeholder.com/150",
                      hasEnded: hasEnded, // Point 1: Pass state to card
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

  Widget _buildEventCard({
    required String title,
    required String date,
    required String location,
    required String imageUrl,
    required bool hasEnded,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: hasEnded ? Colors.grey : const Color(0xffb1170c), 
          width: 2
        ),
      ),
      elevation: 4,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: ColorFiltered(
              colorFilter: hasEnded 
                ? const ColorFilter.mode(Colors.grey, BlendMode.saturation) 
                : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
              child: Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150, 
                  color: Colors.grey[200], 
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: hasEnded ? Colors.grey : Colors.black
                )),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(date, style: const TextStyle(color: Colors.grey)),
                    if (hasEnded) ...[
                      const SizedBox(width: 10),
                      const Text("ENDED", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                    ]
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(location, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: hasEnded ? null : () {
                      // Logic for joining event
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasEnded ? Colors.grey : const Color(0xffb1170c)
                    ),
                    child: Text(
                      hasEnded ? "Event Ended" : "Join Event", 
                      style: const TextStyle(color: Colors.white)
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}