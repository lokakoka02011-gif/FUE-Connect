import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fue_connect/widgets/filter_pills.dart';
class CompanyApprovalPage extends StatefulWidget {
  const CompanyApprovalPage({super.key});

  @override
  State<CompanyApprovalPage> createState() => _CompanyApprovalPageState();
}

class _CompanyApprovalPageState extends State<CompanyApprovalPage> {
  String selectedFilter = "all";

  // UPDATE STATUS
  Future<void> updateStatus(String docId, String status) async {
    await FirebaseFirestore.instance.collection('users').doc(docId).update({
      'approvalStatus': status,
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Company $status")));
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;

      case "rejected":
        return Colors.red;

      case "pending":
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color fueRed = Color(0xffb1170c);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },

      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),

            onPressed: () {
              Navigator.pop(context);
            },
          ),

          title: const Text("Companies"),

          backgroundColor: fueRed,
          foregroundColor: Colors.white,
        ),

        body: Column(
          children: [
            Padding(

              padding:
                  const EdgeInsets.all(12),

              child: FilterPills(

                options: const [
                  "all",
                  "pending",
                  "approved",
                  "rejected",
                ],

                selected: selectedFilter,

                onSelected: (value) {

                  setState(() {

                    selectedFilter = value;
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'company')
                    .snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading companies"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // FILTER COMPANIES
                  final companies = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final status = data['approvalStatus'] ?? 'pending';

                    if (selectedFilter == "all") {
                      return true;
                    }

                    return status == selectedFilter;
                  }).toList();

                  if (companies.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: const [
                          Icon(Icons.business, size: 60, color: Colors.grey),

                          SizedBox(height: 10),

                          Text("No companies found"),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),

                    itemCount: companies.length,

                    itemBuilder: (context, index) {
                      final company = companies[index];

                      final data = company.data() as Map<String, dynamic>;

                      final status = data['approvalStatus'] ?? 'pending';

                      final imageUrl = data['imgUrl'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(16),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Row(
                                children: [
                                  // IMAGE
                                  imageUrl != null &&
                                          imageUrl.toString().isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),

                                          child: Image.network(
                                            imageUrl,

                                            width: 60,
                                            height: 60,

                                            fit: BoxFit.cover,

                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 60,

                                                    height: 60,

                                                    color: Colors.grey[300],

                                                    child: const Icon(
                                                      Icons.broken_image,

                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                          ),
                                        )
                                      : Container(
                                          width: 60,
                                          height: 60,

                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],

                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),

                                          child: const Icon(
                                            Icons.business,

                                            color: Colors.grey,
                                          ),
                                        ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          data['companyName'] ??
                                              "No Company Name",

                                          style: const TextStyle(
                                            fontSize: 20,

                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),

                                          decoration: BoxDecoration(
                                            color: getStatusColor(status),

                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),

                                          child: Text(
                                            status.toUpperCase(),

                                            style: const TextStyle(
                                              color: Colors.white,

                                              fontSize: 11,

                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Text("Email: ${data['email'] ?? 'N/A'}"),

                              const SizedBox(height: 6),

                              Text(
                                "Website: ${data['companyWebsite'] ?? 'N/A'}",
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "Location: ${data['companyLocation'] ?? 'N/A'}",
                              ),

                              const SizedBox(height: 14),

                              Text(
                                data['companyDescription'] ?? "No Description",
                              ),

                              const SizedBox(height: 18),

                              Row(
                                children: [
                                  // APPROVE
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),

                                      onPressed: status == "approved"
                                          ? null
                                          : () => updateStatus(
                                              company.id,
                                              "approved",
                                            ),

                                      child: const Text(
                                        "APPROVE",

                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // REJECT
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),

                                      onPressed: status == "rejected"
                                          ? null
                                          : () => updateStatus(
                                              company.id,
                                              "rejected",
                                            ),

                                      child: const Text(
                                        "REJECT",

                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
