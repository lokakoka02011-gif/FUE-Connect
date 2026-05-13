import 'package:flutter/material.dart';
import 'package:fue_connect/screens/features/management/ManageItemsPage.dart';
import 'package:fue_connect/screens/features/management/CompanyApprovalPage.dart';
import 'package:fue_connect/services/auth_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fue_connect/screens/features/management/AdminLiveChat.dart';
import 'package:fue_connect/screens/features/management/ManageSubscriptionsPage.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() =>
      _AdminDashboardPageState();
}

class _AdminDashboardPageState
    extends State<AdminDashboardPage> {

  int studentsCount = 0;
  int clubsCount = 0;
  int eventsCount = 0;
  int opportunitiesCount = 0;
  int volunteeringCount = 0;
  int postsCount = 0;
  int unreadChatsCount = 0;
  int companiesCount = 0;

  // LOGOUT
  void _handleLogout(
    BuildContext context,
  ) async {

    final authService = AuthService();

    await authService.signOut();

    Navigator.of(context)
        .pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  void _listenToCounts() {

    FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .listen((snapshot) {

      setState(() {
        studentsCount = snapshot.docs.length;
      });
    });

    FirebaseFirestore.instance
        .collection('Clubs')
        .snapshots()
        .listen((snapshot) {

      setState(() {
        clubsCount = snapshot.docs.length;
      });
    });

    FirebaseFirestore.instance
        .collection('Events')
        .snapshots()
        .listen((snapshot) {

      setState(() {
        eventsCount = snapshot.docs.length;
      });
    });

    FirebaseFirestore.instance
        .collection('opportunities')
        .snapshots()
        .listen((snapshot) {

      setState(() {
        opportunitiesCount = snapshot.docs.length;
      });
    });

    FirebaseFirestore.instance
        .collection('volunteer')
        .snapshots()
        .listen((snapshot) {

      setState(() {
        volunteeringCount = snapshot.docs.length;
      });
    });

    FirebaseFirestore.instance
        .collection('posts')
        .snapshots()
        .listen((snapshot) {

      setState(() {
        postsCount = snapshot.docs.length;
      });
    });

    FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'company')
        .snapshots()
        .listen((snapshot) {

      setState(() {
        companiesCount = snapshot.docs.length;
      });
    });

    FirebaseFirestore.instance
        .collection('messages')
        .where('isReadByAdmin', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {

      setState(() {
        unreadChatsCount = snapshot.docs.length;
      });
    });
  }


  @override
  void initState() {
    super.initState();
    _listenToCounts();
  }

  @override
  Widget build(BuildContext context) {

    const Color fueRed =
        Color(0xffb1170c);

    return Scaffold(

      backgroundColor:
          Colors.grey[100],

      appBar: AppBar(

        backgroundColor: fueRed,

        elevation: 0,

        // LIVE CHAT BUTTON
        leading: IconButton(

          icon: const Icon(
            Icons.chat,
            color: Colors.white,
          ),

          onPressed: () {

            Navigator.push(

              context,

              MaterialPageRoute(
                builder: (_) =>
                    const AdminLiveChat(),
              ),
            );
          },
        ),

        title: const Text(

          "Admin Dashboard",

          style: TextStyle(
            color: Colors.white,
          ),
        ),

        actions: [

          IconButton(

            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),

            tooltip: "Logout",

            onPressed: () =>
                _handleLogout(context),
          ),
        ],
      ),

      body: SingleChildScrollView(

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Padding(

              padding:
                  EdgeInsets.all(20),

              child: Text(

                "Dashboard Overview",

                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            Padding(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              child: Container(

                height: 300,

                padding:
                    const EdgeInsets.all(20),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(20),

                  boxShadow: [

                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.05),

                      blurRadius: 10,
                    ),
                  ],
                ),

                child: BarChart(

                  BarChartData(

                    maxY: [

                              studentsCount,
                              clubsCount,
                              eventsCount,
                              opportunitiesCount,
                              volunteeringCount,
                              postsCount,
                              companiesCount,
                              unreadChatsCount,
                            ]
                            .reduce(
                              (a, b) =>
                                  a > b
                                      ? a
                                      : b,
                            )
                            .toDouble() + 5,

                    borderData:
                        FlBorderData(show: false),

                    gridData: FlGridData(

                      show: true,

                      drawVerticalLine: false,

                      horizontalInterval: 2,

                      getDrawingHorizontalLine:
                          (value) {

                        return FlLine(
                          color: Colors.grey
                              .withOpacity(0.12),
                          strokeWidth: 1,
                        );
                      },
                    ),

                    titlesData:
                        FlTitlesData(

                      leftTitles:
                          AxisTitles(

                        sideTitles:
                            SideTitles(

                          showTitles: true,

                          reservedSize: 28,

                          interval: 2,

                          getTitlesWidget:
                              (value, meta) {

                            return Text(

                              value
                                  .toInt()
                                  .toString(),

                              style:
                                  const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),

                      rightTitles:
                          AxisTitles(
                        sideTitles:
                            SideTitles(
                          showTitles: false,
                        ),
                      ),

                      topTitles:
                          AxisTitles(
                        sideTitles:
                            SideTitles(
                          showTitles: false,
                        ),
                      ),

                      bottomTitles:
                          AxisTitles(

                        sideTitles:
                            SideTitles(

                          showTitles: true,

                          reservedSize: 30,

                          getTitlesWidget:
                              (value, meta) {

                            switch (
                                value.toInt()) {

                              case 0:
                                return const Text(
                                  "Students",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                );

                              case 1:
                                return const Text(
                                  "Clubs",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                );

                              case 2:
                                return const Text(
                                  "Events",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                );

                              case 3:
                                return const Text(
                                  "Jobs",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                );

                              case 4:
                                return const Text(
                                  "Volunteer",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                );

                              case 5:
                                return const Text(
                                  "Posts",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                );

                              case 6:
                                return const Text(
                                  "Companies",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                );

                              case 7:
                                return const Text(
                                  "Chats",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                );

                              default:
                                return const SizedBox();
                            }
                          },
                        ),
                      ),
                    ),

                    barGroups: [

                      _barGroup(
                        0,
                        studentsCount.toDouble(),
                        fueRed,
                      ),

                      _barGroup(
                        1,
                        clubsCount.toDouble(),
                        Colors.blue,
                      ),

                      _barGroup(
                        2,
                        eventsCount.toDouble(),
                        Colors.green,
                      ),

                      _barGroup(
                        3,
                        opportunitiesCount.toDouble(),
                        Colors.orange,
                      ),

                      _barGroup(
                        4,
                        volunteeringCount.toDouble(),
                        Colors.purple,
                      ),

                      _barGroup(
                        5,
                        postsCount.toDouble(),
                        Colors.teal,
                      ),

                      _barGroup(
                        6,
                        companiesCount.toDouble(),
                        Colors.red,
                      ),

                      _barGroup(
                        7,
                        unreadChatsCount.toDouble(),
                        Colors.indigo,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Padding(

              padding:
                  EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Text(

                "Manage Platform Content",

                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Padding(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              child: GridView.count(

                crossAxisCount: 2,

                shrinkWrap: true,

                physics:
                    const NeverScrollableScrollPhysics(),

                crossAxisSpacing: 12,
                mainAxisSpacing: 12,

                childAspectRatio: 2.8,

                children: [

                  // STUDENTS
                  _dashboardCard(

                    context,

                    "Students",

                    studentsCount.toString(),

                    Icons.people,

                    fueRed,

                    () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              ManageItemsPage(
                            title: "Students",
                            collectionPath:
                                "users",
                          ),
                        ),
                      );
                    },
                  ),

                  // CLUBS
                  _dashboardCard(

                    context,

                    "Clubs",

                    clubsCount.toString(),

                    Icons.groups,

                    Colors.blue,

                    () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              ManageItemsPage(
                            title: "Clubs",
                            collectionPath:
                                "Clubs",
                          ),
                        ),
                      );
                    },
                  ),

                  // EVENTS
                  _dashboardCard(

                    context,

                    "Events",

                    eventsCount.toString(),

                    Icons.event,

                    Colors.green,

                    () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              ManageItemsPage(
                            title: "Events",
                            collectionPath:
                                "Events",
                          ),
                        ),
                      );
                    },
                  ),

                  // OPPORTUNITIES
                  _dashboardCard(

                    context,

                    "Opportunities",

                    opportunitiesCount
                        .toString(),

                    Icons.work,

                    Colors.orange,

                    () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              ManageItemsPage(
                            title: "Opportunities",
                            collectionPath:
                                "opportunities",
                            isAdmin: true,
                          ),
                        ),
                      );
                    },
                  ),

                  // VOLUNTEERING
                  _dashboardCard(

                    context,

                    "Volunteering",

                    volunteeringCount
                        .toString(),

                    Icons.volunteer_activism,

                    Colors.purple,

                    () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              ManageItemsPage(
                            title:
                                "Volunteering",
                            collectionPath:
                                "volunteering",
                          ),
                        ),
                      );
                    },
                  ),

                  // POSTS
                  _dashboardCard(

                    context,

                    "Posts",

                    postsCount.toString(),

                    Icons.feed,

                    Colors.teal,

                    () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              ManageItemsPage(
                            title: "Posts",
                            collectionPath:
                                "posts",
                          ),
                        ),
                      );
                    },
                  ),

                  // COMPANIES
                  _dashboardCard(

                    context,

                    "Companies",

                    companiesCount.toString(),

                    Icons.business,

                    Colors.red,

                    () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              const CompanyApprovalPage(),
                        ),
                      );
                    },
                  ),

                  // SUBSCRIPTIONS
                  _dashboardCard(

                    context,

                    "Subscriptions",

                    "",

                    Icons.workspace_premium,

                    Colors.amber,

                    () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              const ManageSubscriptionsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(
    int x,
    double value,
    Color color,
  ) {

    return BarChartGroupData(

      x: x,

      barRods: [

        BarChartRodData(

          toY: value,

          width: 26,

          color: color,

          borderRadius:
              BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _dashboardCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {

    return InkWell(

      borderRadius:
          BorderRadius.circular(18),

      onTap: onTap,

      child: Container(

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(18),

          boxShadow: [

            BoxShadow(
              color: Colors.black
                  .withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),

        child: Row(

          children: [

            Container(

              padding:
                  const EdgeInsets.all(10),

              decoration: BoxDecoration(

                color:
                    color.withOpacity(0.12),

                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                size: 22,
                color: color,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(

              child: Column(

                mainAxisAlignment:
                    MainAxisAlignment.center,

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(

                    value,

                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        const TextStyle(

                      fontSize: 18,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(

                    title,

                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        const TextStyle(

                      color: Colors.grey,

                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}