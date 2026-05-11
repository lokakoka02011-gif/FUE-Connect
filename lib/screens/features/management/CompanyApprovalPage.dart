import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyApprovalPage extends StatelessWidget {
  const CompanyApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {

    const Color fueRed =
        Color(0xffb1170c);

    return WillPopScope(

      onWillPop: () async {

        Navigator.pop(context);
        return false;
      },

      child: Scaffold(

        appBar: AppBar(

          leading: IconButton(

            icon:
                const Icon(Icons.arrow_back),

            onPressed: () {
              Navigator.pop(context);
            },
          ),

          title:
              const Text("Company Requests"),

          backgroundColor: fueRed,
          foregroundColor: Colors.white,
        ),

        body: StreamBuilder<QuerySnapshot>(

          stream: FirebaseFirestore.instance
              .collection('users')

              .where(
                'role',
                isEqualTo: 'company',
              )

              .where(
                'approvalStatus',
                isEqualTo: 'pending',
              )

              .snapshots(),

          builder: (context, snapshot) {

            if (snapshot.hasError) {

              return const Center(
                child: Text(
                  "Error loading requests",
                ),
              );
            }

            if (snapshot.connectionState ==
                ConnectionState.waiting) {

              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            final companies =
                snapshot.data!.docs;

            if (companies.isEmpty) {

              return const Center(
                child: Text(
                  "No pending company requests",
                ),
              );
            }

            return ListView.builder(

              padding:
                  const EdgeInsets.all(16),

              itemCount: companies.length,

              itemBuilder: (context, index) {

                final company =
                    companies[index];

                final data =
                    company.data()
                        as Map<String, dynamic>;

                return Card(

                  margin:
                      const EdgeInsets.only(
                    bottom: 16,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),

                  child: Padding(

                    padding:
                        const EdgeInsets.all(
                      16,
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Text(
                          data['companyName'] ??
                              "No Company Name",

                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(
                          "Email: ${data['email'] ?? 'N/A'}",
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          "Website: ${data['companyWebsite'] ?? 'N/A'}",
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          "Location: ${data['companyLocation'] ?? 'N/A'}",
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          data['companyDescription'] ??
                              "No Description",
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        Row(

                          children: [

                            Expanded(

                              child:
                                  ElevatedButton(

                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.green,
                                ),

                                onPressed: () async {

                                  await FirebaseFirestore
                                      .instance
                                      .collection(
                                        'users',
                                      )
                                      .doc(
                                        company.id,
                                      )
                                      .update({

                                    'approvalStatus':
                                        'approved',
                                  });

                                  if (context.mounted) {

                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(

                                      const SnackBar(
                                        content: Text(
                                          "Company approved",
                                        ),
                                      ),
                                    );
                                  }
                                },

                                child: const Text(
                                  "APPROVE",

                                  style: TextStyle(
                                    color:
                                        Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            Expanded(

                              child:
                                  ElevatedButton(

                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.red,
                                ),

                                onPressed: () async {

                                  await FirebaseFirestore
                                      .instance
                                      .collection(
                                        'users',
                                      )
                                      .doc(
                                        company.id,
                                      )
                                      .update({

                                    'approvalStatus':
                                        'rejected',
                                  });

                                  if (context.mounted) {

                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(

                                      const SnackBar(
                                        content: Text(
                                          "Company rejected",
                                        ),
                                      ),
                                    );
                                  }
                                },

                                child: const Text(
                                  "REJECT",

                                  style: TextStyle(
                                    color:
                                        Colors.white,
                                  ),
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
    );
  }
}