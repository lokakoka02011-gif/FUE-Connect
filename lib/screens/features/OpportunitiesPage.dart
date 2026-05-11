import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fue_connect/main.dart'; 
import 'package:fue_connect/widgets/filter_pills.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';
import 'package:fue_connect/screens/features/formsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OpportunitiesPage extends StatefulWidget {
  const OpportunitiesPage({super.key});

  @override
  State<OpportunitiesPage> createState() => _OpportunitiesPageState();
}

class _OpportunitiesPageState extends State<OpportunitiesPage> {
  // store saved opportunities locally 
  final Set<String> _savedOpportunityIds = {};
  String _selectedCategory = "All";
  String _searchQuery = "";
  
  final List<String> _categories = ['All', 'Dentistry', 'Business', 'Tech', 'Engineering'];

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

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) =>
                    setState(() => _searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search opportunities...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xffb1170c),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilterPills(
                options: _categories,
                selected: _selectedCategory,
                onSelected: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 5),
            // tab content
            Expanded(
              child: TabBarView(
                children: [
                  _buildOpportunityList("internship"),
                  _buildOpportunityList("job"),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  Widget _buildOpportunityList(
    String filterType,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection(
                'opportunities',
              )
              .where(
                'status',
                isEqualTo: 'approved',
              )
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Error loading opportunities",
            ),
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: LoadingIndicator(),
          );
        }
        final docs =
            snapshot.data!.docs.where((doc) {
          final data =
              doc.data()
                  as Map<String, dynamic>;
          final title =
              (data['title'] ?? "")
                  .toString()
                  .toLowerCase();
          final typeMatch =
              data['type']
                      ?.toString()
                      .toLowerCase() ==

                  filterType;

          final categoryMatch =

              _selectedCategory ==
                      "All" ||

                  data['category'] ==
                      _selectedCategory;

          return typeMatch &&
              categoryMatch &&
              title.contains(
                _searchQuery,
              );

        }).toList();

        if (docs.isEmpty) {

          return Center(

            child: Column(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                Icon(
                  Icons.work_off_outlined,
                  size: 50,
                  color: Colors.grey[300],
                ),

                const SizedBox(height: 10),

                Text(

                  "No $filterType found in $_selectedCategory",

                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(

          padding:
              const EdgeInsets.all(16),

          itemCount: docs.length,

          itemBuilder: (
            context,
            index,
          ) {

            final docId =
                docs[index].id;

            final data =
                docs[index].data()
                    as Map<String, dynamic>;

            bool isSaved =
                _savedOpportunityIds
                    .contains(docId);

            return UniversalConnectCard(
              title: data['title'] ??
                      'Untitled',

              subtitle: data['description'] ??
                      '',

              imageUrl: data['imageUrl'],

              trailing: IconButton(

                icon: Icon(
                  isSaved
                      ? Icons.bookmark
                      : Icons.bookmark_border,

                  color: isSaved

                      ? const Color(
                          0xffb1170c,
                        )

                      : Colors.grey,
                ),

                onPressed: () =>
                    _toggleSaveOpportunity(
                  docId,
                  data,
                ),
              ),

              infoRows: [

                Row(

                  children: [

                    const Icon(

                      Icons
                          .monetization_on_outlined,

                      size: 16,

                      color: Colors.green,
                    ),

                    const SizedBox(width: 4),

                    Text(

                      "${data['salary'] ?? 'N/A'} EGP",

                      style:
                          const TextStyle(

                        fontWeight:
                            FontWeight.bold,

                        fontSize: 13,
                      ),
                    ),

                    const Spacer(),

                    const Icon(

                      Icons.event_available,

                      size: 16,

                      color:
                          Color(0xffb1170c),
                    ),

                    const SizedBox(width: 4),

                    Text(

                      "Deadline: ${_formatTimestamp(data['deadline'])}",

                      style:
                          const TextStyle(

                        fontSize: 12,

                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],

              onTap: () =>
                  _showOpportunityDetails(
                context,
                docId,
                data,
              ),
            );
          },
        );
      },
    );
  } 

  void _showOpportunityDetails(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {

    String gpaValue =
        data['minimumCgpa']
                ?.toString() ??
            "N/A";
    bool showGPA =
        gpaValue != "N/A";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,

      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),

        padding:
            const EdgeInsets.all(24),

        child: SingleChildScrollView(

          child: Column(

            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Center(

                child: Container(

                  width: 40,
                  height: 4,

                  decoration: BoxDecoration(

                    color:
                        Colors.grey[300],

                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(

                data['title'] ??
                    'Opportunity',

                style:
                    const TextStyle(

                  fontSize: 22,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              _detailRow(

                Icons.payments,

                "Salary: ",

                "${data['salary'] ?? 'N/A'} EGP",
              ),

              if (showGPA)

                _detailRow(

                  Icons.grade,

                  "Min. CGPA: ",

                  gpaValue,
                ),

              _detailRow(

                Icons.calendar_today,

                "Deadline: ",

                _formatTimestamp(
                  data['deadline'],
                ),
              ),

              const Divider(height: 30),

              const Text(

                "Description",

                style: TextStyle(

                  fontWeight:
                      FontWeight.bold,

                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 8),

              Text(

                data['description'] ??

                    'No description provided.',

                style: TextStyle(

                  color:
                      Colors.grey[800],

                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              const Text(

                "Requirements",

                style: TextStyle(

                  fontWeight:
                      FontWeight.bold,

                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 8),

              Text(

                data['requirements'] ??

                    'Standard eligibility.',

                style: TextStyle(

                  color:
                      Colors.grey[800],

                  height: 1.4,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(

                width: double.infinity,
                height: 52,

                child: ElevatedButton(

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        const Color(
                      0xffb1170c,
                    ),

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),

                  onPressed: () {

                    Navigator.pop(
                      context,
                    );

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            FormsPage(
                          data: data,
                        ),
                      ),
                    );
                  },

                  child: const Text(

                    "Apply Now",

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 16,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
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

      Future<void> _toggleSaveOpportunity(
        String docId,
        Map<String, dynamic> data,
      ) async {
        final uid = FirebaseAuth.instance.currentUser?.uid;

        if (uid == null) return;

        final savedRef = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('saved_items')
            .doc(docId);

        final doc = await savedRef.get();

        if (doc.exists) {
          await savedRef.delete();

          setState(() {
            _savedOpportunityIds.remove(docId);
          });
        } else {
          await savedRef.set({
            'title': data['Title'],
            'type': data['Type'],
            'imageUrl': data['imageUrl'],
            'route': '/opportunities',
            'savedAt': Timestamp.now(),
          });

          setState(() {
            _savedOpportunityIds.add(docId);
          });
        }
      }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      return DateFormat('dd MMM yyyy').format(timestamp.toDate());
    }
    return timestamp.toString();
  }
}