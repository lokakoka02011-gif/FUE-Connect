import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';
import 'package:flutter/services.dart';
import 'package:fue_connect/screens/auth/login_screen.dart';
import 'package:fue_connect/screens/features/settings_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final List<int> academicYears = [
    1, 2, 3, 4, 5
  ];

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

  Future<void> _showFirstTimeDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    selectedFaculty = null;
    final doc = await FirebaseFirestore.instance
        .collection(usersCollection)
        .doc(uid)
        .get();

    final data = doc.data() ?? {};

    final nameController =
        TextEditingController(
          text:
              data['fullName'] ??
              '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}',
        );    final emailController = TextEditingController(text: user?.email ?? "");
    final majorController = TextEditingController();
    final minorController = TextEditingController();
    final cgpaController = TextEditingController();
    final phoneController = TextEditingController(
      text: data['phoneNumber'] ?? "",
    );
    final personalEmailController = TextEditingController(
      text: data['personalEmail'] ?? "",
    );
    int? selectedAcademicYear =
        data['academicYear'];
    
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
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                        ),
                      ),

                    DropdownButtonFormField<int>(
                      value: selectedAcademicYear,
                      decoration: const InputDecoration(
                        labelText: "Academic Year",
                      ),
                      items: academicYears.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(
                            year == 1
                                ? "First Year"
                                : year == 2
                                    ? "Second Year"
                                    : year == 3
                                        ? "Third Year"
                                        : year == 4
                                            ? "Fourth Year"
                                            : "Fifth Year",
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedAcademicYear = value;
                        });
                      },
                    ),
                    TextField(
                      controller: personalEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Personal Email",
                        hintText: "example@gmail.com",
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
                  "academicYear": selectedAcademicYear,
                  "phoneNumber": phoneController.text.trim(),
                  "personalEmail": personalEmailController.text.trim(),
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
      int? selectedAcademicYear = data['academicYear'];
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
                  DropdownButtonFormField<int>(
                    value: selectedAcademicYear,
                    decoration: const InputDecoration(
                      labelText: "Academic Year",
                    ),
                    items: academicYears.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(
                          year == 1
                              ? "First Year"
                              : year == 2
                                  ? "Second Year"
                                  : year == 3
                                      ? "Third Year"
                                      : year == 4
                                          ? "Fourth Year"
                                          : "Fifth Year",
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedAcademicYear = value;
                      });
                    },
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
                  if (selectedFaculty == null){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a faculty"),
                      ),
                    );
                    return;
                  }
                  if (selectedAcademicYear == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please select academic year",
                        ),
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
                        "academicYear": selectedAcademicYear,
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

                // profile card
                Container(

                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

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

                  child: Column(

                    children: [

                      Stack(

                        children: [
                          
                          CircleAvatar(
                            radius: 55,
                            backgroundColor:
                                const Color(0xffb1170c),
                            backgroundImage:
                                info['profileImage'] != null &&
                                        info['profileImage']
                                            .toString()
                                            .isNotEmpty
                                    ? NetworkImage(
                                        "${info['profileImage']}?v=${DateTime.now().millisecondsSinceEpoch}",
                                      )
                                    : null,
                            child:
                                info['profileImage'] == null ||
                                        info['profileImage']
                                            .toString()
                                            .isEmpty
                                    ? Text(
                                        fullName.isNotEmpty
                                            ? fullName[0]
                                                .toUpperCase()
                                            : "?",
                                        style: const TextStyle(
                                          fontSize: 40,
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      )
                                    : null,
                          ),                        
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xffb1170c),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: IconButton(
                                onPressed: () {
                                    _uploadProfileImage();
                                },

                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Text(
                        fullName,

                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        info['email'] ?? "",

                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 16),

                      if ((info['description'] ?? "")
                          .toString()
                          .isNotEmpty)

                        Text(
                          info['description'],

                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // academic info card
                Container(

                  width: double.infinity,

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

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        "Academic Information",

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildInfoRow(
                        Icons.school,
                        "Faculty",
                        info['faculty'] ?? 'Not set',
                      ),

                      const SizedBox(height: 12),

                      _buildInfoRow(
                        Icons.menu_book,
                        "Major",
                        info['major'] ?? 'Not set',
                      ),

                      const SizedBox(height: 12),

                      _buildInfoRow(
                        Icons.bookmark,
                        "Minor",
                        info['minor'] ?? 'None',
                      ),

                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.star,
                        "CGPA",
                        info['cgpa'] ?? 'Not set',
                      ),

                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.calendar_today,
                        "Academic Year",
                        info['academicYear'] != null
                            ? "${info['academicYear']}"
                            : 'Not set',
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // clubs card
                Container(

                  width: double.infinity,

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

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        "Club Memberships",

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,

                        children:
                            ((info['clubs'] as List?) ?? [])
                                .map(
                                  (club) => Container(

                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),

                                    decoration: BoxDecoration(
                                      color:
                                          const Color(0xffb1170c),

                                      borderRadius:
                                          BorderRadius.circular(
                                        20,
                                      ),
                                    ),

                                    child: Text(
                                      club.toString(),

                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // interests
                if ((info['interests'] as List?)
                        ?.isNotEmpty ??
                    false)

                  Container(

                    width: double.infinity,

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const Text(
                          "Interests",

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,

                          children:
                              (info['interests'] as List)
                                  .map(
                                    (interest) => Container(

                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),

                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],

                                        borderRadius:
                                            BorderRadius.circular(
                                          20,
                                        ),
                                      ),

                                      child: Text(
                                        interest.toString(),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton.icon(

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xffb1170c),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),

                    onPressed: () {
                      _showEditProfileDialog();
                    },

                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),

                    label: const Text(
                      "Edit Profile",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),              

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
    Future<void> _uploadProfileImage() async {
      try {
        final picker = ImagePicker();
        final pickedFile =
            await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );
        if (pickedFile == null) return;
        final bytes =
            await pickedFile.readAsBytes();

        final ref = FirebaseStorage.instance
            .ref()
            .child(
              'profile_images/$uid.jpg',
            );
        await ref.putData(bytes);
        final imageUrl =
            await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(uid)
            .set({
          'profileImage': imageUrl,
        }, SetOptions(merge: true));              
        final refreshedProfile =
            await _fetchFullProfile();
        setState(() {
          _profileFuture =
              Future.value(
                refreshedProfile,
              );
        });       
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(

            const SnackBar(
              content: Text(
                "Profile image updated",
              ),
            ),
          );
        }

      } catch (e) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(
            content: Text(
              "Upload failed: $e",
            ),
          ),
        );
      }
    } 
 
    Widget _buildInfoRow(
      IconData icon,
      String title,
      String value,
    ) {

      return Row(

        children: [

          Icon(
            icon,
            color: const Color(0xffb1170c),
          ),

          const SizedBox(width: 12),

          Text(
            "$title: ",

            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
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