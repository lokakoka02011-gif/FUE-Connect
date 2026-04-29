import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fue_connect/screens/features/MyApplications.dart';

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
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();

  final String studentsCollection = "students";
  final String skillsCollection = "student_skills";
  final String interestsCollection = "student_interests";

  String _oldDesc = "";
  String _oldSkills = "";
  String _oldInterests = "";

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchFullProfile();
    _checkFirstTimeUser();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _skillsController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  // ---------------- FETCH PROFILE ----------------
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
      _skillsController.text =
          (skillDoc.data() as Map?)?['skills'] ?? "";
      _interestsController.text =
          (interestDoc.data() as Map?)?['interests'] ?? "";
    }

    return {
      "info": studentData,
    };
  }

  // ---------------- FIRST TIME CHECK ----------------
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

  // ---------------- FIRST TIME POPUP ----------------
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

  // ---------------- SAVE PROFILE ----------------
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
      "skills": _skillsController.text,
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

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !isEditing) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xffb1170c)),
          );
        }

        if (!snapshot.hasData || snapshot.data!["info"] == null) {
          return const Center(child: Text("No profile found"));
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

                _buildAcademic(info),

                const SizedBox(height: 20),

                _buildButtons(),

                const SizedBox(height: 10),

                // 🔥 NEW BUTTON
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyApplicationsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment),
                  label: const Text("My Applications"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
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

  // ---------------- BUTTONS ----------------
  Widget _buildButtons() {
    if (!isEditing) {
      return ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _oldDesc = _descriptionController.text;
            _oldSkills = _skillsController.text;
            _oldInterests = _interestsController.text;
            isEditing = true;
          });
        },
        icon: const Icon(Icons.edit),
        label: const Text("Edit Profile"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffb1170c),
          foregroundColor: Colors.white,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () {
            setState(() {
              _descriptionController.text = _oldDesc;
              _skillsController.text = _oldSkills;
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

  // ---------------- ACADEMIC ----------------
  Widget _buildAcademic(Map info) {
    return Column(
      children: [
        _row("Faculty", info['faculty']),
        _row("Major", info['major']),
        _row("GPA", info['gpa']),
      ],
    );
  }

  Widget _row(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value ?? "N/A"),
      ],
    );
  }

  // ---------------- FIELDS ----------------
  Widget _buildFields() {
    return Column(
      children: [
        TextField(
          controller: _descriptionController,
          enabled: isEditing,
          decoration: const InputDecoration(labelText: "Description"),
        ),
        TextField(
          controller: _skillsController,
          enabled: isEditing,
          decoration: const InputDecoration(labelText: "Skills"),
        ),
        TextField(
          controller: _interestsController,
          enabled: isEditing,
          decoration: const InputDecoration(labelText: "Interests"),
        ),
      ],
    );
  }
}