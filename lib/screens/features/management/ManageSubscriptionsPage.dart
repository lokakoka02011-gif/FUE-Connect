import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageSubscriptionsPage
    extends StatefulWidget {

  const ManageSubscriptionsPage({
    super.key,
  });

  @override
  State<ManageSubscriptionsPage>
      createState() =>
          _ManageSubscriptionsPageState();
}

class _ManageSubscriptionsPageState
    extends State<ManageSubscriptionsPage> {

  final Color fueRed =
      const Color(0xffb1170c);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey[100],

      appBar: AppBar(

        title: const Text(
          "Manage Subscriptions",
        ),

        backgroundColor: fueRed,

        foregroundColor:
            Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream:
            FirebaseFirestore.instance
                .collection('users')

                .where(
                  'role',
                  isEqualTo:
                      'company',
                )

                .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

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
                "No companies found",
              ),
            );
          }

          return ListView.builder(

            padding:
                const EdgeInsets.all(
              16,
            ),

            itemCount:
                companies.length,

            itemBuilder:
                (context, index) {

              final company =
                  companies[index];

              final data =
                  company.data()
                      as Map<String, dynamic>;

              return Card(

                margin:
                    const EdgeInsets.only(
                  bottom: 14,
                ),

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child: ListTile(

                  contentPadding:
                      const EdgeInsets.all(
                    16,
                  ),

                  leading: CircleAvatar(

                    backgroundColor:
                        fueRed.withOpacity(
                      0.12,
                    ),

                    child: Icon(
                      Icons.business,
                      color: fueRed,
                    ),
                  ),

                  title: Text(

                    data['companyName']
                            ?.toString() ??
                        "Company",

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle: Padding(

                    padding:
                        const EdgeInsets.only(
                      top: 6,
                    ),

                    child: Text(

                      "Current Plan: "
                      "${data['subscriptionPlan'] ?? "free"}",
                    ),
                  ),

                  trailing:
                      ElevatedButton(

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          fueRed,
                    ),

                    onPressed: () {

                      _showPlanDialog(
                        company.id,
                      );
                    },

                    child: const Text(
                      "Manage",
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showPlanDialog(
      String companyId) {

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text(
            "Select Plan",
          ),

          content: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              _planButton(
                companyId,
                "free",
                0,
              ),

              _planButton(
                companyId,
                "silver",
                30,
              ),

               _planButton(
                companyId,
                "silver",
                180,
              ),

              _planButton(
                companyId,
                "gold",
                30,
              ), 

              _planButton(
                companyId,
                "gold",
                180,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _planButton(
    String companyId,
    String plan,
    int durationDays,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: SizedBox(

        width:
            double.infinity,

        child: ElevatedButton(

          onPressed: () async {

            DateTime? endDate;

            if (plan != "free") {

              endDate =
                  DateTime.now().add(

                Duration(
                  days: durationDays,
                ),
              );
            }

            await FirebaseFirestore.instance
                .collection('users')
                .doc(companyId)
                .update({

              "subscriptionPlan":
                  plan,

              "subscriptionActive":
                  true,

              "subscriptionEnd": endDate != null
                ? Timestamp.fromDate(endDate)
                : null,
            });

            if (mounted) {

              Navigator.pop(context);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(

                SnackBar(

                  content: Text(
                    "$plan plan activated",
                  ),
                ),
              );
            }
          },

          child: Text(
            plan == "free"
                ? "FREE"
                : "${plan.toUpperCase()} - "
                  "${durationDays == 30 ? "1 MONTH" : "6 MONTHS"}",          ),
        ),
      ),
    );
  }
}