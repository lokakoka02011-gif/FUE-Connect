import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fue_connect/screens/features/MyApplications.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';
import 'package:fue_connect/screens/auth/login_screen.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isEditing = false;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  late Future<Map<String, dynamic>> _profileFuture;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();

  Set<String> _selectedSkills = {};

  final List<String> allSkills = [
    "Flutter",
    "Firebase",
    "UI/UX",
    "Marketing",
    "Design",
    "Data Analysis",
  ];

  final String studentsCollection = "students";
  final String skillsCollection = "student_skills";
  final String interestsCollection = "student_interests";

  String _oldDesc = "";
  Set<String> _oldSkills = {};
  String _oldInterests = "";

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchFullProfile();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeUser();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

// fetch profile data w load skills/interests from Firestore
  Future<Map<String, dynamic>> _fetchFullProfile() async {
    if (uid == null) return {};

    final results = await Future.wait([
      FirebaseFirestore.instance.collection(studentsCollection).doc(uid).get(),
      FirebaseFirestore.instance.collection(skillsCollection).doc(uid).get(),
      FirebaseFirestore.instance.collection(interestsCollection).doc(uid).get(),
    ]);

    final studentDoc = results[0];
    final skillDoc = results[1];
    final interestDoc = results[2];

    final studentData =
        studentDoc.data() as Map<String, dynamic>? ?? {};

    if (!isEditing) {
      _descriptionController.text = studentData['description'] ?? "";
      _interestsController.text =
          (interestDoc.data() as Map?)?['interests'] ?? "";

      final skillsData = (skillDoc.data() as Map?)?['skills'];
      if (skillsData is List) {
        _selectedSkills = Set<String>.from(skillsData);
      }
    }

    return {
      "info": studentData,
    };
  }

// first time user yemla personal info
  Future<void> _checkFirstTimeUser() async {
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection(studentsCollection)
        .doc(uid)
        .get();

    final data = doc.data();
    final isComplete = data?['isProfileComplete'] ?? false;

    if (!isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFirstTimeDialog();
      });
    }
  }

  void _showFirstTimeDialog() {
    final user = FirebaseAuth.instance.currentUser;

    final nameController =
        TextEditingController(text: user?.displayName ?? "");
    final emailController =
        TextEditingController(text: user?.email ?? "");
    final facultyController = TextEditingController();
    final majorController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Complete Your Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                TextField(
                  controller: emailController,
                  enabled: false,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: facultyController,
                  decoration: const InputDecoration(labelText: "Faculty"),
                ),
                TextField(
                  controller: majorController,
                  decoration: const InputDecoration(labelText: "Major"),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection(studentsCollection)
                    .doc(uid)
                    .set({
                  "first_name": nameController.text.split(" ").first,
                  "last_name": nameController.text.split(" ").length > 1
                      ? nameController.text.split(" ").sublist(1).join(" ")
                      : "",
                  "email": emailController.text,
                  "faculty": facultyController.text,
                  "major": majorController.text,
                  "isProfileComplete": true,
                }, SetOptions(merge: true));

                Navigator.pop(context);

                setState(() {
                  _profileFuture = _fetchFullProfile();
                });
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

// save updated profile + convert selected skills to list for Firestore
  void _saveData() async {
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection(studentsCollection)
        .doc(uid)
        .update({
      "description": _descriptionController.text,
    });

    await FirebaseFirestore.instance
        .collection(skillsCollection)
        .doc(uid)
        .set({
      "skills": _selectedSkills.toList(),
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection(interestsCollection)
        .doc(uid)
        .set({
      "interests": _interestsController.text,
    }, SetOptions(merge: true));

    setState(() {
      isEditing = false;
      _profileFuture = _fetchFullProfile();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !isEditing) {
          return const Scaffold(
            body: Center(
              child: LoadingIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!["info"] == null) {
          return const Scaffold(
            body: Center(child: Text("No profile found")),
          );
        }

        final info = snapshot.data!["info"];
        final fullName =
            "${info['first_name'] ?? ''} ${info['last_name'] ?? ''}";

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xffb1170c),
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 15),
                Text(fullName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Text(info['email'] ?? "",
                    style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 20),

                _buildButtons(),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text("Log Out"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Log Out"),
                            content: const Text(
                              "Are you sure you want to log out?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text("Log Out"),
                              ),
                            ],
                          ),
                        );
                        if (shouldLogout == true) {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      },
                    ),
                  ),

                  const Divider(height: 40),
                _buildFields(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtons() {
    if (!isEditing) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            _oldDesc = _descriptionController.text;
            _oldSkills = Set.from(_selectedSkills);
            _oldInterests = _interestsController.text;
            isEditing = true;
          });
        },
        child: const Text("Edit Profile"),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () {
            setState(() {
              _descriptionController.text = _oldDesc;
              _selectedSkills = _oldSkills;
              _interestsController.text = _oldInterests;
              isEditing = false;
            });
          },
          child: const Text("Cancel"),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _saveData,
          child: const Text("Save"),
        ),
      ],
    );
  }

  Widget _buildFields() {
    return Column(
      children: [
        TextField(
          controller: _descriptionController,
          enabled: isEditing,
          decoration: const InputDecoration(labelText: "Description"),
        ),

        const SizedBox(height: 10),
        
      // selectable skills (tap to add/remove, prevents duplicates, shows selection)
        Wrap(
          spacing: 8,
          children: allSkills.map((skill) {
            final isSelected = _selectedSkills.contains(skill);

            return GestureDetector(
              onTap: () {
                if (!isEditing) return;

                setState(() {
                  if (isSelected) {
                    _selectedSkills.remove(skill);
                  } else {
                    _selectedSkills.add(skill);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xffb1170c)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: _interestsController,
          enabled: isEditing,
          decoration: const InputDecoration(labelText: "Interests"),
        ),
      ],
    );
  }
}