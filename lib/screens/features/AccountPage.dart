import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';
import 'package:flutter/services.dart';
import 'package:fue_connect/screens/auth/login_screen.dart';
import 'package:fue_connect/screens/features/settings_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  late Future<Map<String, dynamic>> _profileFuture;

  final TextEditingController _descriptionController = TextEditingController();

  Set<String> _selectedSkills = {};
  Set<String> _selectedClubs = {};
  List<String> _selectedInterests = [];
  List<String> _clubNames = [];
  String? selectedFaculty;
  final List<String> faculties = [
    "Dentistry",
    "Business",
    "Economics and Political Science",
    "Engineering",
    "Computer Science",
  ];
  List<String> allSkills = [];

  final String usersCollection = "users";
  final String skillsCollection = "student_skills";


  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchFullProfile();
    _loadClubs();
    _loadSkills();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeUser();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

// fetch profile data w load skills/interests from Firestore
  Future<Map<String, dynamic>> _fetchFullProfile() async {
    if (uid == null) return {};

    final results = await Future.wait([
      FirebaseFirestore.instance.collection(usersCollection).doc(uid).get(),
      FirebaseFirestore.instance.collection(skillsCollection).doc(uid).get(),
    ]);

    final studentDoc = results[0];
    final skillDoc = results[1];

    final studentData =
        studentDoc.data() ?? {};
        final clubsData = studentData['clubs'];

        if (clubsData is List) {
          _selectedClubs = Set<String>.from(clubsData);
        }
        final interestsData = studentData['interests'];

        if (interestsData is List) {
          _selectedInterests =
              List<String>.from(interestsData);
        }

        final skillsData = (skillDoc.data() as Map?)?['skills'];

        if (skillsData is List) {
          _selectedSkills =
              Set<String>.from(skillsData);
        }

    return {
      "info": studentData,
    };
  }

// first time user yemla personal info
  Future<void> _checkFirstTimeUser() async {
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection(usersCollection)
        .doc(uid)
        .get();

    final data = doc.data();
    final isComplete = data?['profileCompleted'] ?? false;

    if (!isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFirstTimeDialog();
      });
    }
  }

  void _showFirstTimeDialog() {
    final user = FirebaseAuth.instance.currentUser;
    selectedFaculty = null;
    final nameController =
        TextEditingController(text: user?.displayName ?? "");
    final emailController =
        TextEditingController(text: user?.email ?? "");
    final majorController = TextEditingController();
    final minorController = TextEditingController();
    final cgpaController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                    DropdownButtonFormField<String>(
                      value: selectedFaculty,
                      decoration: const InputDecoration(
                        labelText: "Faculty",
                      ),
                      items: faculties.map((faculty) {
                        return DropdownMenuItem(
                          value: faculty,
                          child: Text(faculty),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedFaculty = value;
                        });
                      },
                    ),
                    TextField(
                      controller: majorController,
                      decoration: const InputDecoration(labelText: "Major"),
                    ),
                    TextField(
                      controller: minorController,
                      decoration: const InputDecoration(
                        labelText: "Minor (Optional)",
                      ),
                    ),
                      TextField(
                        controller: cgpaController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: "CGPA",
                          hintText: "e.g. 3.75",
                        ),
                      ),

                const SizedBox(height: 16),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Club Memberships (Optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _clubNames.map((club) {
                    final isSelected =
                        _selectedClubs.contains(club);

                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          if (isSelected) {
                            _selectedClubs.remove(club);
                          } else {
                            _selectedClubs.add(club);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xffb1170c)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          club,
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (selectedFaculty == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select a faculty"),
                    ),
                  );
                  return;
                }
                final cgpa =
                    double.tryParse(cgpaController.text);

                if (cgpa == null || cgpa < 0 || cgpa > 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("CGPA must be between 0 and 4"),
                    ),
                  );
                  return;
                }
                await FirebaseFirestore.instance
                    .collection(usersCollection)
                    .doc(uid)
                    .set({
                  "firstName":
                      nameController.text.trim().split(" ").first,

                  "lastName":
                      nameController.text.trim().split(" ").length > 1
                          ? nameController.text
                              .trim()
                              .split(" ")
                              .sublist(1)
                              .join(" ")
                          : "",

                  "fullName": nameController.text.trim(),

                  "email": emailController.text,

                  "faculty": selectedFaculty,

                  "major": majorController.text.trim(),

                  "minor": minorController.text.trim(),

                  "cgpa": cgpaController.text.trim(),

                  "clubs": _selectedClubs.toList(),

                  "profileCompleted": true,

                  "updatedAt": FieldValue.serverTimestamp(),
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
      },
    );
  }


    Future<void> _showEditProfileDialog() async{
      final user = FirebaseAuth.instance.currentUser;
      final doc = await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(uid)
          .get();
      final data = doc.data() ?? {};
      selectedFaculty = data['faculty'];
      final nameController =
          TextEditingController(
            text: data['fullName'] ?? user?.displayName ?? "",
          );
      final emailController =
          TextEditingController(text: user?.email ?? "");
      final majorController = TextEditingController(
          text: data['major'] ?? "",
      );
      final minorController = TextEditingController(
          text: data['minor'] ?? "",
      );
      final cgpaController = TextEditingController(
          text: data['cgpa'] ?? "",
      );
      final descriptionController =
          TextEditingController(
        text: data['description'] ?? "",
      );
      final skillSearchController =
          TextEditingController();  
      List<String> filteredSkills = allSkills;        
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
          builder: (context, setDialogState) {
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
                  DropdownButtonFormField<String>(
                    value: selectedFaculty,
                    decoration: const InputDecoration(
                      labelText: "Faculty",
                    ),
                    items: faculties.map((faculty) {
                      return DropdownMenuItem(
                        value: faculty,
                        child: Text(faculty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedFaculty = value;
                      });
                    },
                  ),
                  TextField(
                    controller: majorController,
                    decoration: const InputDecoration(labelText: "Major"),
                  ),
                  TextField(
                    controller: minorController,
                    decoration: const InputDecoration(
                      labelText: "Minor (Optional)",
                    ),
                  ),
                    TextField(
                      controller: cgpaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: "CGPA",
                        hintText: "e.g. 3.75",
                      ),
                    ),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                    ),

                  const SizedBox(height: 16),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Club Memberships (Optional)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _clubNames.map((club) {
                      final isSelected =
                          _selectedClubs.contains(club);

                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            if (isSelected) {
                              _selectedClubs.remove(club);
                            } else {
                              _selectedClubs.add(club);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xffb1170c)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            club,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
const SizedBox(height: 20),

const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Skills (Optional)",
    style: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 10),

TextField(
  controller: skillSearchController,
  decoration: const InputDecoration(
    hintText: "Search skills...",
    prefixIcon: Icon(Icons.search),
  ),
  onChanged: (value) {
    setDialogState(() {
      filteredSkills = allSkills
          .where(
            (skill) => skill
                .toLowerCase()
                .contains(value.toLowerCase()),
          )
          .toList();
    });
  },
),
    const SizedBox(height: 10),

    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filteredSkills.map((skill) {
        final isSelected =
            _selectedSkills.contains(skill);

        return GestureDetector(
          onTap: () {
            setDialogState(() {
              if (isSelected) {
                _selectedSkills.remove(skill);
              } else {
                _selectedSkills.add(skill);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xffb1170c)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              skill,
              style: TextStyle(
                color:
                    isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    ),
    const SizedBox(height: 20),

    const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Interests",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    const SizedBox(height: 10),

    TextField(
      decoration: const InputDecoration(
        hintText: "Type interest and press enter",
      ),
      onSubmitted: (value) {
        final trimmed = value.trim();

        if (trimmed.isEmpty) return;

        if (!_selectedInterests.contains(trimmed)) {
          setDialogState(() {
            _selectedInterests.add(trimmed);
          });
        }
      },
    ),

    const SizedBox(height: 10),

    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _selectedInterests.map((interest) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xffb1170c),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                interest,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 6),

              GestureDetector(
                onTap: () {
                  setDialogState(() {
                    _selectedInterests.remove(interest);
                  });
                },
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ),    
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (selectedFaculty == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a faculty"),
                      ),
                    );
                    return;
                  }
                  final cgpa =
                      double.tryParse(cgpaController.text);

                  if (cgpa == null || cgpa < 0 || cgpa > 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("CGPA must be between 0 and 4"),
                      ),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance
                      .collection(usersCollection)
                      .doc(uid)
                      .set({
                        "firstName":
                            nameController.text.trim().split(" ").first,

                        "lastName":
                            nameController.text.trim().split(" ").length > 1
                                ? nameController.text
                                    .trim()
                                    .split(" ")
                                    .sublist(1)
                                    .join(" ")
                                : "",
                        "fullName": nameController.text.trim(),        
                        "email": emailController.text,
                        "faculty": selectedFaculty,
                        "major": majorController.text.trim(),
                        "minor": minorController.text.trim(),
                        "cgpa": cgpaController.text.trim(),
                        "clubs": _selectedClubs.toList(),
                        "interests": _selectedInterests,
                        "profileCompleted": true,
                        "updatedAt": FieldValue.serverTimestamp(),
                        "description":
                          descriptionController.text.trim(),                                        
                  }, SetOptions(merge: true));
                  await FirebaseFirestore.instance
                      .collection(skillsCollection)
                      .doc(uid)
                      .set({
                    "skills": _selectedSkills.toList(),
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
      },
    );
  }

// save updated profile + convert selected skills to list for Firestore

  Future<void> _loadSkills() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('skills')
        .get();

    setState(() {
      allSkills = snapshot.docs
          .map((doc) => doc['name'].toString())
          .toList();
    });
  }

  Future<void> _loadClubs() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Clubs')
        .get();

    setState(() {
      _clubNames = snapshot.docs
          .map((doc) => doc['name'].toString())
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
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
            "${info['firstName'] ?? ''} ${info['lastName'] ?? ''}";

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
                const SizedBox(height: 10),

                Text(
                  "Faculty: ${info['faculty'] ?? 'Not set'}",
                ),

                Text(
                  "Major: ${info['major'] ?? 'Not set'}",
                ),

                Text(
                  "Minor: ${info['minor'] ?? 'None'}",
                ),
                Text(
                  "CGPA: ${info['cgpa'] ?? 'Not set'}",
                ),
                const SizedBox(height: 8),

                Text(
                  "Clubs: ${(info['clubs'] as List?)?.join(', ') ?? 'None'}",
                ),
                const SizedBox(height: 12),

                Text(
                  info['description'] ?? "",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if ((info['interests'] as List?)?.isNotEmpty ?? false)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Interests",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            (info['interests'] as List)
                                .map(
                                  (interest) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffb1170c),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      interest.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),

            

                _buildButtons(),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text("Settings"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtons() {
    return ElevatedButton(
        onPressed: () {
          _showEditProfileDialog();
        },
        child: const Text("Edit Profile"),
      );  
  }
}