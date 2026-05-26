import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApplicantsPage extends StatefulWidget {
  const ApplicantsPage({super.key});

  @override
  State<ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  final Color fueRed = const Color(0xffb1170c);

  bool isLoading = true;

  String subscriptionPlan = "free";

  int unlockLimit = 3;

  int unlocksUsed = 0;

  List<String> unlockedApplicants = [];

  @override
  void initState() {
    super.initState();
    loadCompanyData();
  }

  Future<void> loadCompanyData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final data = userDoc.data() ?? {};

      subscriptionPlan = data['subscriptionPlan'] ?? 'free';

      unlocksUsed = data['applicantUnlocksUsed'] ?? 0;

      unlockedApplicants = List<String>.from(data['unlockedApplicants'] ?? []);

      // unlock limits based on plan
      if (subscriptionPlan == "free") {
        unlockLimit = 3;
      } else if (subscriptionPlan == "silver") {
        unlockLimit = 10;
      } else if (subscriptionPlan == "gold"){
        unlockLimit = -1;
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool isUnlocked(String applicantId) {
    return unlockedApplicants.contains(applicantId);
  }

  Future<void> unlockApplicant(String applicantId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    // unlimited unlocks for pro
    if (unlockLimit != -1 && unlocksUsed >= unlockLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You reached your unlock limit, please upgrade to unlock")),
      );

      return;
    }

    unlockedApplicants.add(applicantId);

    unlocksUsed++;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({
          'unlockedApplicants': unlockedApplicants,

          'applicantUnlocksUsed': unlocksUsed,
        });

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Applicants"),

        backgroundColor: fueRed,

        foregroundColor: Colors.white,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // unlock usage card
                Container(
                  margin: const EdgeInsets.all(16),

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(20),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),

                        blurRadius: 10,
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      Icon(Icons.lock_open, color: fueRed, size: 30),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              subscriptionPlan.toUpperCase(),

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,

                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              unlockLimit == -1
                                  ? "Unlimited applicant unlocks"
                                  : "$unlocksUsed / $unlockLimit applicant unlocks used",

                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('applications')
                        .where('companyId', isEqualTo: currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text("Error loading applicants"),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;
                      docs.sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>;

                        final bData = b.data() as Map<String, dynamic>;

                        final aDate =
                            (aData['appliedAt'] as Timestamp?)?.toDate() ??
                            DateTime(2000);

                        final bDate =
                            (bData['appliedAt'] as Timestamp?)?.toDate() ??
                            DateTime(2000);

                        return bDate.compareTo(aDate);
                      });

                      if (docs.isEmpty) {
                        return const Center(child: Text("No applicants yet"));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),

                        itemCount: docs.length,

                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;

                          final applicantId = docs[index].id;

                          final unlocked = isUnlocked(applicantId);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(18),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,

                                        backgroundColor:
                                            fueRed.withOpacity(0.1),

                                        backgroundImage:
                                            data['profileImage'] !=
                                                        null &&
                                                    data['profileImage']
                                                        .toString()
                                                        .isNotEmpty
                                                ? NetworkImage(
                                                    data['profileImage'],
                                                  )
                                                : null,

                                        child:
                                            data['profileImage'] ==
                                                        null ||
                                                    data['profileImage']
                                                        .toString()
                                                        .isEmpty
                                                ? Icon(
                                                    Icons.person,
                                                    color: fueRed,
                                                  )
                                                : null,
                                      ),

                                      const SizedBox(width: 14),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            Text(
                                              data['studentName'] ??
                                                  'Student',

                                              style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,

                                                fontSize: 18,
                                              ),
                                            ),

                                            const SizedBox(height: 4),

                                            Text(
                                              data['faculty'] ??
                                                  'Faculty',

                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 18),

                                  _infoRow(
                                    Icons.work_outline,
                                    "Applied For",
                                    data['opportunityTitle'] ??
                                        'Opportunity',
                                  ),

                                  const SizedBox(height: 10),

                                  _infoRow(
                                    Icons.grade,
                                    "CGPA",
                                    data['cgpa']?.toString() ??
                                        'N/A',
                                  ),

                                  const SizedBox(height: 10),

                                  _infoRow(
                                    Icons.school_outlined,
                                    "Major",
                                    data['major'] ?? 'N/A',
                                  ),

                                  const SizedBox(height: 10),

                                  _infoRow(
                                    Icons.lightbulb_outline,
                                    "Skills",
                                    (data['skills'] as List?)
                                            ?.join(', ') ??
                                        'No skills',
                                  ),

                                  const Divider(height: 30),

                                  if (unlocked) ...[
                                    _infoRow(
                                      Icons.phone_outlined,
                                      "Phone",
                                      data['studentPhone'] ??
                                          'N/A',
                                    ),

                                    const SizedBox(height: 10),

                                    _infoRow(
                                      Icons.email_outlined,
                                      "Email",
                                      data['studentEmail'] ??
                                          'No email',
                                    ),

                                    const SizedBox(height: 10),

                                    if ((data['cvUrl'] ?? '')
                                        .toString()
                                        .isNotEmpty)
                                      SizedBox(
                                        width: double.infinity,

                                        child: ElevatedButton.icon(
                                          style:
                                              ElevatedButton.styleFrom(
                                            backgroundColor:
                                                fueRed,
                                          ),

                                          onPressed: () {
                                            // later open CV
                                          },

                                          icon: const Icon(
                                            Icons.picture_as_pdf,
                                            color: Colors.white,
                                          ),

                                          label: const Text(
                                            "View CV",

                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ] else ...[
                                    Container(
                                      padding:
                                          const EdgeInsets.all(14),

                                      decoration: BoxDecoration(
                                        color: Colors.orange
                                            .withOpacity(0.08),

                                        borderRadius:
                                            BorderRadius.circular(
                                          14,
                                        ),
                                      ),

                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.lock_outline,
                                            color: Colors.orange,
                                          ),

                                          const SizedBox(width: 12),

                                          const Expanded(
                                            child: Text(
                                              "Contact information hidden",
                                            ),
                                          ),

                                          ElevatedButton(
                                            style:
                                                ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  fueRed,
                                            ),

                                            onPressed: () =>
                                                unlockApplicant(
                                              applicantId,
                                            ),

                                            child: const Text(
                                              "Unlock",

                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(icon, size: 18, color: fueRed),

        const SizedBox(width: 10),

        Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),

        Expanded(child: Text(value)),
      ],
    );
  }
}
