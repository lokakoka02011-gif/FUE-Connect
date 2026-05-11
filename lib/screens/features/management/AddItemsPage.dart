import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fue_connect/widgets/loading_indicator.dart';

class AddEditItemPage extends StatefulWidget {
  final String collectionPath;
  final String? docId;
  final Map<String, dynamic>? itemData;

  const AddEditItemPage({
    super.key,
    required this.collectionPath,
    this.docId,
    this.itemData,
  });

  @override
  State<AddEditItemPage> createState() => _AddEditItemPageState();
}

class _AddEditItemPageState extends State<AddEditItemPage> {
  final _formKey = GlobalKey<FormState>();

  // COMMON
  final titleController = TextEditingController();

  final descController = TextEditingController();

  final locationController = TextEditingController();

  // OPPORTUNITIES
  final requirementsController = TextEditingController();

  final salaryController = TextEditingController();

  final cgpaController = TextEditingController();

  // USERS
  final studentIdController = TextEditingController();

  final facultyController = TextEditingController();

  final majorController = TextEditingController();

  final minorController = TextEditingController();

  final academicYearController = TextEditingController();

  final studentCgpaController = TextEditingController();

  // POSTS
  final clubNameController = TextEditingController();

  // STATES
  String selectedType = "internship";

  String selectedCategory = "Tech";

  String selectedVisibility = "public";

  DateTime? selectedDeadline;

  bool isLoading = false;

  File? selectedImage;

  String? existingImageUrl;

  List<String> allSkills = [];

  Set<String> selectedSkills = {};

  String companyName = "";

  final List<String> categories = [
    "Tech",
    "Business",
    "Engineering",
    "Dentistry",
  ];

  // COLLECTION TYPES
  bool get isOpportunities => widget.collectionPath == "opportunities";

  bool get isUsers => widget.collectionPath == "users";

  bool get isPosts => widget.collectionPath == "posts";

  bool get isClubs => widget.collectionPath == "Clubs";

  bool get isEvents => widget.collectionPath == "Events";

  bool get isVolunteering => widget.collectionPath == "volunteering";

  bool get isEdit => widget.docId != null;

  @override
  void initState() {
    super.initState();

    loadSkills();
    loadCompanyData();

    if (widget.itemData != null) {
      final data = widget.itemData!;

      // COMMON
      titleController.text = data["title"] ?? data["name"] ?? "";

      descController.text = data["description"] ?? data["content"] ?? "";

      existingImageUrl = data["imgUrl"];

      locationController.text = data["location"] ?? "";

      selectedType = data["type"] ?? "internship";

      selectedCategory = data["category"] ?? "Tech";

      // OPPORTUNITIES
      requirementsController.text = data["requirements"] ?? "";

      salaryController.text = data["salary"]?.toString() ?? "";

      cgpaController.text = data["minimumCgpa"]?.toString() ?? "";

      if (data["requiredSkills"] != null) {
        selectedSkills = Set<String>.from(data["requiredSkills"]);
      }

      if (data["deadline"] != null && data["deadline"] is Timestamp) {
        selectedDeadline = (data["deadline"] as Timestamp).toDate();
      }

      // POSTS
      selectedVisibility = data["visibility"] ?? "public";

      clubNameController.text = data["clubName"] ?? "";

      // USERS
      studentIdController.text = data["studentId"] ?? "";

      facultyController.text = data["faculty"] ?? "";

      majorController.text = data["major"] ?? "";

      minorController.text = data["minor"] ?? "";

      academicYearController.text = data["academicYear"] ?? "";

      studentCgpaController.text = data["cgpa"]?.toString() ?? "";
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    requirementsController.dispose();
    salaryController.dispose();
    locationController.dispose();
    cgpaController.dispose();

    studentIdController.dispose();
    facultyController.dispose();
    majorController.dispose();
    minorController.dispose();
    academicYearController.dispose();
    studentCgpaController.dispose();

    clubNameController.dispose();

    super.dispose();
  }

  // LOAD COMPANY
  Future<void> loadCompanyData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data() ?? {};

    setState(() {
      companyName = data['companyName'] ?? "Company";
    });
  }

  // LOAD SKILLS
  Future<void> loadSkills() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('skills')
        .get();

    setState(() {
      allSkills = snapshot.docs.map((doc) => doc['name'].toString()).toList();
    });
  }

  // PICK IMAGE
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,

      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  // PICK DATE
  Future<void> pickDeadline() async {
    final pickedDate = await showDatePicker(
      context: context,

      firstDate: DateTime.now(),

      lastDate: DateTime(2035),

      initialDate: selectedDeadline ?? DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDeadline = pickedDate;
      });
    }
  }

  // SAVE ITEM
  Future<void> saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? imageUrl = existingImageUrl;

      // UPLOAD IMAGE
      if (selectedImage != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();

        final ref = FirebaseStorage.instance
            .ref()
            .child(widget.collectionPath)
            .child("$fileName.jpg");

        await ref.putFile(selectedImage!);

        imageUrl = await ref.getDownloadURL();
      }

      final currentUser = FirebaseAuth.instance.currentUser;

      final Map<String, dynamic> data = {
        // COMMON
        "imgUrl": imageUrl,

        "updatedAt": FieldValue.serverTimestamp(),

        // OPPORTUNITIES
        if (isOpportunities) ...{
          "title": titleController.text.trim(),

          "description": descController.text.trim(),

          "type": selectedType,

          "providerName": companyName,

          "requirements": requirementsController.text.trim(),

          "salary": int.tryParse(salaryController.text) ?? 0,

          "category": selectedCategory,

          "minimumCgpa": cgpaController.text.trim().isEmpty
              ? null
              : double.tryParse(cgpaController.text),

          "location": locationController.text.trim(),

          "requiredSkills": selectedSkills.toList(),

          "deadline": selectedDeadline == null
              ? null
              : Timestamp.fromDate(selectedDeadline!),

          if (!isEdit) "status": "pending",

          if (!isEdit) "applicationCount": 0,

          if (!isEdit) "featured": false,
        },

        // POSTS
        if (isPosts) ...{
          "title": titleController.text.trim(),

          "content": descController.text.trim(),

          "clubName": clubNameController.text.trim(),

          "visibility": selectedVisibility,
        },

        // USERS
        if (isUsers) ...{
          "name": titleController.text.trim(),

          "studentId": studentIdController.text.trim(),

          "faculty": facultyController.text.trim(),

          "major": majorController.text.trim(),

          "minor": minorController.text.trim(),

          "academicYear": academicYearController.text.trim(),

          "cgpa": double.tryParse(studentCgpaController.text),
        },

        // CLUBS
        if (isClubs) ...{
          "name": titleController.text.trim(),

          "description": descController.text.trim(),
        },

        // EVENTS
        if (isEvents) ...{
          "title": titleController.text.trim(),

          "description": descController.text.trim(),

          "location": locationController.text.trim(),

          "date": selectedDeadline == null
              ? null
              : Timestamp.fromDate(selectedDeadline!),
        },

        // VOLUNTEERING
        if (isVolunteering) ...{
          "title": titleController.text.trim(),

          "description": descController.text.trim(),

          "location": locationController.text.trim(),

          "deadline": selectedDeadline == null
              ? null
              : Timestamp.fromDate(selectedDeadline!),
        },

        if (!isEdit) "createdAt": FieldValue.serverTimestamp(),

        if (!isEdit) "createdBy": currentUser?.uid,
      };

      // CREATE
      if (!isEdit) {
        await FirebaseFirestore.instance
            .collection(widget.collectionPath)
            .add(data);
      } else {
        // UPDATE
        await FirebaseFirestore.instance
            .collection(widget.collectionPath)
            .doc(widget.docId)
            .update(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit ? "Updated successfully" : "Added successfully",
            ),

            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color fueRed = Color(0xffb1170c);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? "Edit ${widget.collectionPath}"
              : "Add ${widget.collectionPath}",
        ),

        backgroundColor: fueRed,

        foregroundColor: Colors.white,
      ),

      body: isLoading
          ? const Center(child: LoadingIndicator())
          : Form(
              key: _formKey,

              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // IMAGE
                    GestureDetector(
                      onTap: pickImage,

                      child: Container(
                        height: 200,

                        width: double.infinity,

                        decoration: BoxDecoration(
                          color: Colors.grey[200],

                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),

                                child: kIsWeb
                                    ? Image.network(
                                        selectedImage!.path,

                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        selectedImage!,

                                        fit: BoxFit.cover,
                                      ),
                              )
                            : existingImageUrl != null &&
                                  existingImageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),

                                child: Image.network(
                                  existingImageUrl!,

                                  fit: BoxFit.cover,

                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],

                                      child: const Icon(
                                        Icons.broken_image,

                                        size: 50,

                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.add_a_photo,

                                size: 50,

                                color: Colors.grey,
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TITLE
                    TextFormField(
                      controller: titleController,

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Required";
                        }

                        return null;
                      },

                      decoration: InputDecoration(
                        labelText: isUsers
                            ? "Student Name"
                            : isClubs
                            ? "Club Name"
                            : "Title",

                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // DESCRIPTION
                    TextFormField(
                      controller: descController,

                      maxLines: 4,

                      decoration: InputDecoration(
                        labelText: isPosts ? "Content" : "Description",

                        border: const OutlineInputBorder(),
                      ),
                    ),

                    // USERS
                    if (isUsers) ...[
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: studentIdController,

                        decoration: const InputDecoration(
                          labelText: "Student ID",

                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: facultyController,

                        decoration: const InputDecoration(
                          labelText: "Faculty",

                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: majorController,

                        decoration: const InputDecoration(
                          labelText: "Major",

                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: minorController,

                        decoration: const InputDecoration(
                          labelText: "Minor",

                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: academicYearController,

                        decoration: const InputDecoration(
                          labelText: "Academic Year",

                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: studentCgpaController,

                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),

                        decoration: const InputDecoration(
                          labelText: "CGPA",

                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],

                    // POSTS
                    if (isPosts) ...[
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: clubNameController,

                        decoration: const InputDecoration(
                          labelText: "Club Name (Optional)",

                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: selectedVisibility,

                        decoration: const InputDecoration(
                          labelText: "Visibility",

                          border: OutlineInputBorder(),
                        ),

                        items: const [
                          DropdownMenuItem(
                            value: "public",

                            child: Text("Public"),
                          ),

                          DropdownMenuItem(
                            value: "clubExclusive",

                            child: Text("Club Exclusive"),
                          ),
                        ],

                        onChanged: (value) {
                          setState(() {
                            selectedVisibility = value!;
                          });
                        },
                      ),
                    ],

                    // OPPORTUNITIES
                    if (isOpportunities) ...[
                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: selectedType,

                        decoration: const InputDecoration(
                          labelText: "Type",

                          border: OutlineInputBorder(),
                        ),

                        items: const [
                          DropdownMenuItem(
                            value: "internship",

                            child: Text("Internship"),
                          ),

                          DropdownMenuItem(value: "job", child: Text("Job")),
                        ],

                        onChanged: (value) {
                          setState(() {
                            selectedType = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: selectedCategory,

                        decoration: const InputDecoration(
                          labelText: "Category",

                          border: OutlineInputBorder(),
                        ),

                        items: categories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),

                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 30),

                    // SAVE
                    SizedBox(
                      width: double.infinity,

                      height: 52,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: fueRed,
                        ),

                        onPressed: saveItem,

                        child: Text(
                          isEdit ? "UPDATE" : "SAVE",

                          style: const TextStyle(
                            color: Colors.white,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
