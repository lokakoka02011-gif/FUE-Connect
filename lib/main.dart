import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fue_connect/screens/features/management/AdminDashboardPage.dart';
import 'firebase_options.dart';
import 'package:fue_connect/screens/features/StudentLiveChat.dart';

// Services
import 'package:fue_connect/services/auth_service.dart';

// Screens
import 'package:fue_connect/screens/home/HomePage.dart';
import 'package:fue_connect/screens/features/ClubsPage.dart';
import 'package:fue_connect/screens/features/AccountPage.dart';
import 'package:fue_connect/screens/features/EventsPage.dart';
import 'package:fue_connect/screens/features/SearchPage.dart';
import 'package:fue_connect/screens/features/VolunteerPage.dart';
import 'package:fue_connect/screens/features/NotificationPage.dart';
import 'package:fue_connect/screens/auth/login_screen.dart';
import 'package:fue_connect/screens/features/SupportPage.dart';
import 'package:fue_connect/screens/features/AboutUsPage.dart';
import 'package:fue_connect/screens/features/GpaCalculator.dart';
import 'package:fue_connect/screens/features/ChatPage.dart';
import 'package:fue_connect/screens/features/CampusMapPage.dart';
import 'package:fue_connect/screens/features/AcademicCalendarPage.dart';
import 'package:fue_connect/screens/features/SavedItemsPage.dart';
import 'screens/features/settings_page.dart';
import 'package:fue_connect/screens/features/jobsPage.dart';
import 'package:fue_connect/screens/features/internshipsPage.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xffb1170c),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const LoginScreen(),
      routes: {
        '/main': (context) => const MainPage(),
        '/login': (context) => const LoginScreen(),
        '/clubs': (context) => const ClubsPage(),
        '/events': (context) => const EventsPage(),
        '/volunteer': (context) => const VolunteerPage(),
        '/notification': (context) => const NotificationPage(),
        '/support': (context) => const SupportPage(),
        '/about': (context) => const AboutUsPage(),
        '/gpa': (context) => const GpaCalculator(),
        '/chat': (context) => const ChatPage(),
        '/map': (context) => const CampusMapPage(),
        '/calendar': (context) => const AcademicCalendarPage(),
        '/saved': (context) => const SavedItemsPage(),
        '/admin_dashboard': (context) => const AdminDashboardPage(),
        '/settings': (context) => const SettingsPage(),
        '/chat': (context) => const StudentLiveChat(),
        '/jobs': (context) => const JobsPage(),
        '/internships': (context) =>
    const InternshipsPage(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    SearchPage(),
    AccountPage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {Color color = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FUE CONNECT"),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

              return Padding(
                padding: const EdgeInsets.only(right: 10, top: 5),
                child: Badge(
                  label: Text('$unreadCount'),
                  isLabelVisible: unreadCount > 0,
                  backgroundColor: Colors.white,
                  textColor: const Color(0xffb1170c),
                  child: IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () => Navigator.pushNamed(context, '/notification'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ✅ FIXED USER FETCH (ONLY CHANGE)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                String name = "FUE Student";
                String email = FirebaseAuth.instance.currentUser?.email ?? "student@fue.edu.eg";

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  name = "${data['firstName']} ${data['lastName']}";
                }

                return Container(
                  color: const Color(0xffb1170c),
                  padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.school, size: 40, color: Color(0xffb1170c)),
                      ),
                      const SizedBox(height: 15),
                      Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],



                  ),
                );
              },
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(Icons.calculate_outlined, "GPA Calculator", () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/gpa');
                  }),
                  _buildMenuItem(Icons.map_outlined, "Campus Map", () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/map');
                  }),
                  _buildMenuItem(Icons.calendar_month_outlined, "Academic Calendar", () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/calendar');
                  }),
                  const Divider(),
                  _buildMenuItem(Icons.bookmark_border, "Saved Items", () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/saved');
                  }),
                  _buildMenuItem(Icons.info_outline_rounded, "About FUE Connect", () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/about');
                  }),
                  _buildMenuItem(Icons.support_agent_rounded, "Support & FAQs", () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/support');
                  }),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildMenuItem(
              Icons.logout_rounded,
              "Logout",
              () async {
                await AuthService().signOut();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
              color: Colors.red,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        backgroundColor: const Color(0xffb1170c),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

// --- UNIVERSAL COMPONENTS (UNCHANGED) ---

class UniversalConnectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final Widget? trailing;
  final List<Widget> infoRows;
  final VoidCallback onTap;
  final bool isFeatured;

  const UniversalConnectCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.trailing,
    required this.infoRows,
    required this.onTap,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isFeatured ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isFeatured ? const BorderSide(color: Color(0xffb1170c), width: 1.5) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  imageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(height: 140, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                      if (trailing != null) trailing!,
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 12),
                  ...infoRows,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffb1170c) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xffb1170c), width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}