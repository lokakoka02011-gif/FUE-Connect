import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fue_connect/screens/auth/login_screen.dart';
import 'package:fue_connect/screens/features/management/AddItemsPage.dart';
import 'package:fue_connect/screens/features/management/ManageItemsPage.dart';
import 'package:fue_connect/screens/features/management/ApplicantsPage.dart';

class CompanyDashboard extends StatefulWidget {
  const CompanyDashboard({super.key});

  @override
  State<CompanyDashboard> createState() =>
      _CompanyDashboardState();
}

class _CompanyDashboardState
    extends State<CompanyDashboard> {

  final Color fueRed =
      const Color(0xffb1170c);

  bool _isLoading = true;

  String companyName = "Company";

  String approvalStatus = "pending";

  bool companyProfileCompleted = false;

  String subscriptionPlan = "free";
  int totalPosts = 0;
  int approvedPosts = 0;
  int rejectedPosts = 0;
  int applicationsCount = 0;
  int postsLimit = 1;
  int unlockLimit = 10;

  bool featuredAllowed = false;
  Timestamp? subscriptionEnd;
  bool subscriptionActive = true;

  @override
  void initState() {
    super.initState();
    loadCompanyData();
  }

  Future<void> loadCompanyData() async {

    try {

      final currentUser =
          FirebaseAuth.instance.currentUser;

      if (currentUser == null) return;

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

      final userData =
          userDoc.data()
              as Map<String, dynamic>;

      companyName =
          userData['companyName'] ??
              "Company";

      approvalStatus =
          userData['approvalStatus'] ??
              "pending";

      companyProfileCompleted =
          userData['companyProfileCompleted'] ??
              false;

      subscriptionPlan = userData['subscriptionPlan'] ??
              "free";
    
      subscriptionEnd =
          userData['subscriptionEnd'];
      subscriptionActive =
          userData['subscriptionActive']
              ?? true;

      if (subscriptionPlan == "silver") {

        postsLimit = 5;

        unlockLimit = 50;

        featuredAllowed = false;

      } else if (subscriptionPlan == "gold") {
        postsLimit = -1;
        unlockLimit = -1;
        featuredAllowed = true;

      } else {

        postsLimit = 1;
        unlockLimit = 10;
        featuredAllowed = false;
      }

    if (subscriptionEnd != null) {
      final expiryDate =
          subscriptionEnd!.toDate();
      if (DateTime.now()
          .isAfter(expiryDate)) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          "subscriptionPlan":
              "free",
          "subscriptionActive":
              false,
          "subscriptionEnd":
              null,
        });

        subscriptionPlan = "free";
        subscriptionActive = false;
        postsLimit = 1;
        unlockLimit = 10;
        featuredAllowed = false;
      }
    }

      final postsSnapshot =
          await FirebaseFirestore.instance
              .collection('opportunities')
              .where(
                'createdBy',
                isEqualTo:
                    currentUser.uid,
              )
              .get();

        totalPosts = postsSnapshot.docs.where((doc) {
              final status =
                  doc['status'];
              return status != "rejected";
            }).length;

      final approvedSnapshot =
          await FirebaseFirestore.instance
              .collection('opportunities')
              .where(
                'createdBy',
                isEqualTo:
                    currentUser.uid,
              )
              .where(
                'status',
                isEqualTo:
                    'approved',
              )
              .get();

      approvedPosts =
          approvedSnapshot.docs.length;

      final rejectedSnapshot =
          await FirebaseFirestore.instance
              .collection('opportunities')
              .where(
                'createdBy',
                isEqualTo:
                    currentUser.uid,
              )
              .where(
                'status',
                isEqualTo:
                    'rejected',
              )
              .get();

      rejectedPosts =
          rejectedSnapshot.docs.length;

      final applicationsSnapshot =
          await FirebaseFirestore.instance
              .collection('applications')
              .where(
                'companyId',
                isEqualTo:
                    currentUser.uid,
              )
              .get();

      applicationsCount =
          applicationsSnapshot.docs.length;

      if (mounted) {

        setState(() {
          _isLoading = false;
        });
      }

    } catch (e) {

      if (mounted) {

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> logout() async {

    await FirebaseAuth.instance.signOut();

    if (mounted) {

      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(
          builder: (_) =>
              const LoginScreen(),
        ),

        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    if (!companyProfileCompleted &&
        !_isLoading) {

      return CompleteCompanyProfilePage(
        onComplete: loadCompanyData,
      );
    }

    if (approvalStatus != "approved" &&
        !_isLoading) {

      return Scaffold(

        backgroundColor:
            Colors.grey[100],

        appBar: AppBar(

          automaticallyImplyLeading:
              false,

          title:
              const Text(
            "Pending Approval",
          ),

          backgroundColor:
              fueRed,

          foregroundColor:
              Colors.white,

          actions: [

            IconButton(
              onPressed: logout,
              icon:
                  const Icon(Icons.logout),
            ),
          ],
        ),

        body: Center(

          child: Padding(

            padding:
                const EdgeInsets.all(
              24,
            ),

            child: Column(

              mainAxisAlignment:
                  MainAxisAlignment
                      .center,

              children: [

                Icon(
                  Icons
                      .hourglass_top_rounded,

                  size: 90,

                  color: fueRed,
                ),

                const SizedBox(
                    height: 24),

                const Text(

                  "Your company account is waiting for admin approval.",

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(

                    fontSize: 22,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                    height: 14),

                const Text(

                  "You will gain access once an administrator reviews your company.",

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(

      backgroundColor:
          Colors.grey[100],

      appBar: AppBar(

        automaticallyImplyLeading:
            false,

        title:
            const Text(
          "Company Dashboard",
        ),

        backgroundColor:
            fueRed,

        foregroundColor:
            Colors.white,

        elevation: 0,

        actions: [

          IconButton(
            onPressed: logout,
            icon:
                const Icon(Icons.logout),
          ),
        ],
      ),

      body: _isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(
                16,
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  // welcome card
                  Container(

                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets.all(
                      22,
                    ),

                    decoration:
                        BoxDecoration(

                      color: fueRed,

                      borderRadius:
                          BorderRadius.circular(
                        24,
                      ),
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Text(

                          "Welcome $companyName 👋",

                          style:
                              const TextStyle(

                            color:
                                Colors.white,

                            fontSize: 26,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                            height: 8),

                        const Text(

                          "Manage opportunities, applicants, and subscriptions.",

                          style: TextStyle(

                            color:
                                Colors.white70,

                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // my subscription
                  GestureDetector(

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SubscriptionPlansPage(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(
                        18,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),

                        border: Border.all(
                          color: fueRed,
                          width: 2,
                        ),
                      ),

                      child: Row(

                        children: [

                          Icon(
                            Icons.workspace_premium,
                            color: fueRed,
                          ),

                          const SizedBox(width: 12),

                          Expanded(

                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                const Text(

                                  "MY SUBSCRIPTION",

                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${subscriptionPlan.toUpperCase()} "
                                      "${subscriptionActive ? '(ACTIVE)' : '(EXPIRED)'}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (subscriptionEnd != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(
                                          top: 4,
                                        ),
                                        child: Text(
                                          "Expires: "
                                          "${subscriptionEnd!.toDate().day}/"
                                          "${subscriptionEnd!.toDate().month}/"
                                          "${subscriptionEnd!.toDate().year}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // analytics
                  GridView.count(

                    crossAxisCount: 4,

                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    crossAxisSpacing: 8,

                    mainAxisSpacing: 8,

                    childAspectRatio: 0.9,

                    children: [

                      _miniStatCard(
                        value:
                            totalPosts.toString(),
                        label: "Posts",
                        icon: Icons.work,
                        color: fueRed,
                      ),

                      _miniStatCard(
                        value:
                            approvedPosts.toString(),
                        label: "Approved",
                        icon: Icons.check,
                        color: Colors.green,
                      ),

                      _miniStatCard(
                        value:
                            rejectedPosts.toString(),
                        label: "Rejected",
                        icon: Icons.close,
                        color: Colors.red,
                      ),

                      _miniStatCard(
                        value:
                            applicationsCount
                                .toString(),
                        label: "Applicants",
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(

                    "Quick Actions",

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildDashboardCard(

                    context: context,

                    icon:
                        Icons.work_outline,

                    title:
                        "Manage Opportunities",

                    subtitle:
                        "Edit and manage your posts",

                    color: fueRed,

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ManageItemsPage(
                            title:
                                'Manage Opportunities',
                            collectionPath:
                                'opportunities',
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                _buildDashboardCard(
                  context: context,
                  icon:
                      Icons.add_circle_outline,
                  title:
                      "Add Opportunity",
                  subtitle:
                      "Create a new job or internship",
                  color: Colors.green,
                  onTap: () {
                    if (postsLimit != -1 &&
                        totalPosts >= postsLimit) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            subscriptionPlan == "free"
                                ? "Free plan allows only 1 active post."
                                : "You reached your plan limit.",
                          ),
                        ),
                      );

                      return;
                    }

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const AddEditItemPage(

                          collectionPath:
                              'opportunities',
                        ),
                      ),
                    );
                  },
                ),

                  const SizedBox(height: 14),

                  _buildDashboardCard(

                    context: context,

                    icon:
                        Icons.groups_outlined,

                    title:
                        "Applicants",

                    subtitle:
                        "View student applications",

                    color: Colors.orange,

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              const ApplicantsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _miniStatCard({

    required String value,

    required String label,

    required IconData icon,

    required Color color,
  }) {

    return Container(

      padding:
          const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 6,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        boxShadow: [

          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.03,
            ),

            blurRadius: 8,
          ),
        ],
      ),

      child: Column(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            color: color,
            size: 18,
          ),

          const SizedBox(height: 6),

          Text(

            value,

            style: const TextStyle(

              fontWeight:
                  FontWeight.bold,

              fontSize: 18,
            ),
          ),

          const SizedBox(height: 2),

          Text(

            label,

            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({

    required BuildContext context,

    required IconData icon,

    required String title,

    required String subtitle,

    required Color color,

    required VoidCallback onTap,
  }) {

    return Card(

      elevation: 1,

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

        leading: Container(

          padding:
              const EdgeInsets.all(
            12,
          ),

          decoration:
              BoxDecoration(

            color:
                color.withOpacity(
              0.12,
            ),

            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),

          child:
              Icon(icon, color: color),
        ),

        title: Text(

          title,

          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        subtitle: Text(subtitle),

        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),

        onTap: onTap,
      ),
    );
  }
}

class CompleteCompanyProfilePage
    extends StatefulWidget {

  final VoidCallback onComplete;

  const CompleteCompanyProfilePage({
    super.key,
    required this.onComplete,
  });

  @override
  State<CompleteCompanyProfilePage>
      createState() =>
          _CompleteCompanyProfilePageState();
}

class _CompleteCompanyProfilePageState
    extends State<CompleteCompanyProfilePage> {

  final companyNameController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  final websiteController =
      TextEditingController();

  final locationController =
      TextEditingController();

  bool isLoading = false;

  final Color fueRed =
      const Color(0xffb1170c);

  Future<void> saveCompanyData() async {

    setState(() {
      isLoading = true;
    });

    try {

      final currentUser =
          FirebaseAuth.instance.currentUser;

      if (currentUser == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({

        "companyName":
            companyNameController.text,

        "companyDescription":
            descriptionController.text,

        "companyWebsite":
            websiteController.text,

        "companyLocation":
            locationController.text,

        "companyProfileCompleted":
            true,

        "approvalStatus":
            "pending",
      });

      widget.onComplete();

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content:
              Text("Error: $e"),
        ),
      );

    } finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey[100],

      appBar: AppBar(

        automaticallyImplyLeading:
            false,

        title: const Text(
          "Complete Company Profile",
        ),

        backgroundColor:
            fueRed,

        foregroundColor:
            Colors.white,
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          children: [

            _buildField(
              controller:
                  companyNameController,
              label:
                  "Company Name",
            ),

            const SizedBox(height: 16),

            _buildField(
              controller:
                  descriptionController,
              label:
                  "Company Description",
              maxLines: 4,
            ),

            const SizedBox(height: 16),

            _buildField(
              controller:
                  websiteController,
              label:
                  "Company Website",
            ),

            const SizedBox(height: 16),

            _buildField(
              controller:
                  locationController,
              label:
                  "Company Location",
            ),

            const SizedBox(height: 30),

            SizedBox(

              width:
                  double.infinity,

              height: 55,

              child: ElevatedButton(

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      fueRed,

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),

                onPressed:
                    isLoading
                        ? null
                        : saveCompanyData,

                child:

                    isLoading

                        ? const CircularProgressIndicator(
                            color:
                                Colors.white,
                          )

                        : const Text(

                            "SAVE COMPANY INFO",

                            style: TextStyle(

                              color:
                                  Colors.white,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({

    required TextEditingController
        controller,

    required String label,

    int maxLines = 1,
  }) {

    return TextField(

      controller: controller,

      maxLines: maxLines,

      decoration: InputDecoration(

        labelText: label,

        filled: true,

        fillColor: Colors.white,

        border:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(
            16,
          ),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class SubscriptionPlansPage
    extends StatefulWidget {

  const SubscriptionPlansPage({
    super.key,
  });

  @override
  State<SubscriptionPlansPage>
      createState() =>
          _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState
    extends State<SubscriptionPlansPage> {

  final Color fueRed =
      const Color(0xffb1170c);

  bool silver6Months = false;

  bool gold6Months = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey[100],

      appBar: AppBar(

        automaticallyImplyLeading:
            false,

        title:
            const Text(
          "My Subscription",
        ),

        backgroundColor:
            fueRed,

        foregroundColor:
            Colors.white,

        actions: [

          IconButton(

            onPressed: () {
              Navigator.pop(context);
            },

            icon:
                const Icon(Icons.close),
          ),
        ],
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(
          16,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // current plan
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                20,
              ),

              decoration:
                  BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  22,
                ),

                border: Border.all(
                  color: fueRed,
                  width: 2,
                ),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(

                    "CURRENT PLAN",

                    style: TextStyle(

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(

                    "FREE",

                    style: TextStyle(

                      fontSize: 30,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _usageRow(
                    "Posts Remaining",
                    "1",
                  ),

                  const SizedBox(height: 12),

                  _usageRow(
                    "Applicant Unlocks",
                    "10",
                  ),

                  const SizedBox(height: 12),

                  _usageRow(
                    "Featured Posts",
                    "Unavailable",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(

              "Upgrade Plans",

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            _planCard(

              title: "SILVER",

              monthlyPrice:
                  "299 EGP",

              sixMonthPrice:
                  "1499 EGP",

              sixMonths:
                  silver6Months,

              color: Colors.grey,

              features: [

                "5 active posts",

                "50 applicant unlocks",

                "Priority review",

                "Longer visibility",
              ],

              onChanged: (value) {

                setState(() {
                  silver6Months =
                      value;
                });
              },
            ),

            const SizedBox(height: 20),

            _planCard(

              title: "GOLD",

              monthlyPrice:
                  "599 EGP",

              sixMonthPrice:
                  "2999 EGP",

              sixMonths: gold6Months,

              color: const Color(0xffD4AF37),

              features: [

                "Unlimited posts",

                "Unlimited unlocks",

                "Featured opportunities",

                "Homepage priority",

                "Highest visibility",
              ],

              onChanged: (value) {

                setState(() {
                  gold6Months =
                      value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _usageRow(
    String title,
    String value,
  ) {

    return Row(

      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,

      children: [

        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _planCard({

    required String title,

    required String monthlyPrice,

    required String sixMonthPrice,

    required bool sixMonths,

    required Color color,

    required List<String> features,

    required Function(bool)
        onChanged,
  }) {

    return Container(

      width: double.infinity,

      padding:
          const EdgeInsets.all(
        20,
      ),

      decoration:
          BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        border: Border.all(
          color:
              color.withOpacity(0.5),
          width: 2,
        ),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(

            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              Text(

                title,

                style: TextStyle(

                  fontSize: 28,

                  fontWeight:
                      FontWeight.bold,

                  color: color,
                ),
              ),

              Switch(

                value: sixMonths,

                activeColor: color,

                onChanged: onChanged,
              ),
            ],
          ),

          Text(

            sixMonths
                ? "6 Months"
                : "Monthly",

            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 20),

          Text(

            sixMonths
                ? sixMonthPrice
                : monthlyPrice,

            style: const TextStyle(

              fontSize: 30,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          ...features.map(

            (feature) => Padding(

              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),

              child: Row(

                children: [

                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: 22,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(feature),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(

            width: double.infinity,

            child: ElevatedButton(

              style:
                  ElevatedButton.styleFrom(

                backgroundColor:
                    color,

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 16,
                ),

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),

              onPressed: () {

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(

                  const SnackBar(

                    content: Text(
                      "Call us on 1234 to subscribe",
                    ),
                  ),
                );
              },

              child: const Text(

                "CALL US ON 1234",

                style: TextStyle(

                  color: Colors.white,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}                  