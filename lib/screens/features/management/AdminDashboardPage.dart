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
  int pendingCompaniesCount = 0;
  int pendingOpportunitiesCount = 0;

  // logout
  void _handleLogout(
    BuildContext context,
  ) async {

    final authService =
        AuthService();

    await authService.signOut();

    Navigator.of(context)
        .pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  Future<void> _loadCounts() async {

    final students =
        await FirebaseFirestore.instance
            .collection('users')
            .get();

    final clubs =
        await FirebaseFirestore.instance
            .collection('Clubs')
            .get();

    final events =
        await FirebaseFirestore.instance
            .collection('Events')
            .get();

    final opportunities =
        await FirebaseFirestore.instance
            .collection('opportunities')
            .get();

    final pendingOpportunities =
        await FirebaseFirestore.instance
            .collection('opportunities')

            .where(
              'status',
              isEqualTo: 'pending',
            )

            .get();

    final volunteering =
        await FirebaseFirestore.instance
            .collection('volunteering')
            .get();

    final posts =
        await FirebaseFirestore.instance
            .collection('club_posts')
            .get();

    final pendingCompanies =
        await FirebaseFirestore.instance
            .collection('users')

            .where(
              'role',
              isEqualTo: 'company',
            )

            .where(
              'approvalStatus',
              isEqualTo: 'pending',
            )

            .get();

    final unreadChats =
        await FirebaseFirestore.instance
            .collection('support_chats')

            .where(
              'isReadByAdmin',
              isEqualTo: false,
            )

            .get();

    setState(() {

      studentsCount =
          students.docs.length;

      clubsCount =
          clubs.docs.length;

      eventsCount =
          events.docs.length;

      opportunitiesCount =
          opportunities.docs.length;

      pendingOpportunitiesCount =
          pendingOpportunities.docs.length;

      volunteeringCount =
          volunteering.docs.length;

      postsCount =
          posts.docs.length;

      pendingCompaniesCount =
          pendingCompanies.docs.length;

      unreadChatsCount =
          unreadChats.docs.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  @override
  Widget build(BuildContext context) {

    const Color fueRed =
        Color(0xffb1170c);

    return Scaffold(

      backgroundColor:
          Colors.grey[100],

      appBar: AppBar(

        title: const Text(
          "Admin Dashboard",

          style: TextStyle(
            color: Colors.white,
          ),
        ),

        backgroundColor: fueRed,

        elevation: 0,

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

                height: 320,

                padding:
                    const EdgeInsets.all(
                  20,
                ),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),

                  boxShadow: [

                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                        0.05,
                      ),

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
                              pendingOpportunitiesCount,
                              volunteeringCount,
                              postsCount,
                              pendingCompaniesCount,
                              unreadChatsCount,
                            ]
                            .reduce(
                              (a, b) =>
                                  a > b
                                      ? a
                                      : b,
                            )
                            .toDouble() +
                        5,

                    borderData:
                        FlBorderData(
                      show: false,
                    ),

                    gridData: FlGridData(

                      show: true,

                      drawVerticalLine:
                          false,

                      horizontalInterval:
                          2,

                      getDrawingHorizontalLine:
                          (value) {

                        return FlLine(
                          color: Colors.grey
                              .withOpacity(
                            0.12,
                          ),

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

                          reservedSize:
                              28,

                          interval: 2,

                          getTitlesWidget:
                              (
                            value,
                            meta,
                          ) {

                            return Text(
                              value
                                  .toInt()
                                  .toString(),

                              style:
                                  const TextStyle(
                                fontSize: 11,
                                color:
                                    Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),

                      rightTitles:
                          AxisTitles(
                        sideTitles:
                            SideTitles(
                          showTitles:
                              false,
                        ),
                      ),

                      topTitles:
                          AxisTitles(
                        sideTitles:
                            SideTitles(
                          showTitles:
                              false,
                        ),
                      ),

                      bottomTitles:
                          AxisTitles(

                        sideTitles:
                            SideTitles(

                          showTitles:
                              true,

                          reservedSize:
                              30,

                          getTitlesWidget:
                              (
                            value,
                            meta,
                          ) {

                            switch (
                                value
                                    .toInt()) {

                              case 0:
                                return const Text(
                                  "Users",
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
                                  "Pending",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                );

                              case 5:
                                return const Text(
                                  "Volunteer",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                );

                              case 6:
                                return const Text(
                                  "Posts",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                );

                              case 7:
                                return const Text(
                                  "Companies",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                );

                              case 8:
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
                        studentsCount
                            .toDouble(),
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
                        opportunitiesCount
                            .toDouble(),
                        Colors.orange,
                      ),

                      _barGroup(
                        4,
                        pendingOpportunitiesCount
                            .toDouble(),
                        Colors.deepOrange,
                      ),

                      _barGroup(
                        5,
                        volunteeringCount
                            .toDouble(),
                        Colors.purple,
                      ),

                      _barGroup(
                        6,
                        postsCount.toDouble(),
                        Colors.teal,
                      ),

                      _barGroup(
                        7,
                        pendingCompaniesCount
                            .toDouble(),
                        Colors.red,
                      ),

                      _barGroup(
                        8,
                        unreadChatsCount
                            .toDouble(),
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

                  _dashboardCard(

                    context,

                    "Students",

                    studentsCount.toString(),

                    Icons.people,

                    fueRed,

                    () {},
                  ),

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
                            collectionPath:  "opportunities",
                            isAdmin: true,
                          ),
                        ),
                      );
                    },
                  ),

                  _dashboardCard(

                    context,

                    "Pending Jobs",

                    pendingOpportunitiesCount
                        .toString(),

                    Icons.pending_actions,

                    Colors.deepOrange,

                    () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              ManageItemsPage(
                            title: "Pending Opportunities",
                            collectionPath: "opportunities",
                            isAdmin: true,
                          ),
                        ),
                      );
                    },
                  ),

                  _dashboardCard(

                    context,

                    "Volunteering",

                    volunteeringCount
                        .toString(),

                    Icons
                        .volunteer_activism,

                    Colors.purple,

                    () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              ManageItemsPage(

                            title: "Volunteering",

                            collectionPath: "volunteering",
                          ),
                        ),
                      );
                    },
                  ),

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
                            collectionPath: "club_posts",
                          ),
                        ),
                      );
                    },
                  ),

                  _dashboardCard(

                    context,

                    "Companies",

                    pendingCompaniesCount
                        .toString(),

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

                  _dashboardCard(

                    context,

                    "Live Chat",

                    unreadChatsCount
                        .toString(),

                    Icons.chat,

                    Colors.indigo,

                    () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              const AdminLiveChat(),
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
              BorderRadius.circular(
            8,
          ),
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
                    color.withOpacity(
                  0.12,
                ),

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
                    MainAxisAlignment
                        .center,

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(

                    value,

                    overflow:
                        TextOverflow
                            .ellipsis,

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
                        TextOverflow
                            .ellipsis,

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