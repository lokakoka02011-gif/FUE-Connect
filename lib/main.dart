import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Services
import 'package:fue_connect/services/auth_service.dart';

// Screens
import 'package:fue_connect/screens/home/HomePage.dart';
import 'package:fue_connect/screens/features/ClubsPage.dart';
import 'package:fue_connect/screens/features/AccountPage.dart';
import 'package:fue_connect/screens/features/EventsPage.dart';
import 'package:fue_connect/screens/features/InternshipsPage.dart';
import 'package:fue_connect/screens/features/SearchPage.dart';
import 'package:fue_connect/screens/features/VolunteerPage.dart';
import 'package:fue_connect/screens/features/NotificationPage.dart';
import 'package:fue_connect/screens/auth/login_screen.dart';

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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xffb1170c),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
      ),
      home: const LoginScreen(),
      routes: {
        '/main': (context) => const MainPage(),
        '/clubs': (context) => const ClubsPage(),
        '/events': (context) => const EventsPage(),
        '/volunteer': (context) => const VolunteerPage(),
        '/internships': (context) => const InternshipsPage(),
        '/notification': (context) => const NotificationPage(),
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

  // Helper for drawer menu items
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
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 5),
            child: Badge(
              label: const Text('1'),
              isLabelVisible: true,
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.pushNamed(context, '/notification');
                },
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. DYNAMIC HEADER
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                String name = "FUE Student";
                String email = FirebaseAuth.instance.currentUser?.email ?? "student@fue.edu.eg";

                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
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
                      Text(
                        name,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),

            // 2. APP DESCRIPTION
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Connecting FUE students to the best clubs, events, and career opportunities.",
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),

            const Divider(height: 1),

            // 3. NAVIGATION ITEMS
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(Icons.calculate_outlined, "GPA Calculator", () {}),
                  _buildMenuItem(Icons.map_outlined, "Campus Map", () {}),
                  _buildMenuItem(Icons.calendar_month_outlined, "Academic Calendar", () {}),
                  const Divider(),
                  _buildMenuItem(Icons.bookmark_border, "Saved Items", () {}),
                  _buildMenuItem(Icons.support_agent_rounded, "Support & FAQs", () {}),
                ],
              ),
            ),

            // 4. LOGOUT
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
        type: BottomNavigationBarType.fixed, // Keeps labels visible
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}