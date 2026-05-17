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
  State<AddEditItemPage> createState() =>
      _AddEditItemPageState();
}

class _AddEditItemPageState
    extends State<AddEditItemPage> {
  final _formKey = GlobalKey<FormState>();

  // COMMON
  final titleController = TextEditingController();

  final descController = TextEditingController();

  final locationController =
      TextEditingController();

  // OPPORTUNITIES
  final requirementsController =
      TextEditingController();

  final salaryController =
      TextEditingController();

  final cgpaController =
      TextEditingController();

  final tagsController =
      TextEditingController();

  final eligibleMajorsController =
      TextEditingController();

  // USERS
  final studentIdController =
      TextEditingController();

  final facultyController =
      TextEditingController();

  final majorController =
      TextEditingController();

  final minorController =
      TextEditingController();

  final academicYearController =
      TextEditingController();

  final studentCgpaController =
      TextEditingController();

  // POSTS
  final clubNameController =
      TextEditingController();

  // STATES
  String selectedType = "internship";

  String selectedCategory = "Tech";

  String selectedWorkMode = "Onsite";

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
  bool get isOpportunities =>
      widget.collectionPath ==
      "opportunities";

  bool get isUsers =>
      widget.collectionPath == "users";

  bool get isPosts =>
      widget.collectionPath == "posts";

  bool get isClubs =>
      widget.collectionPath == "Clubs";

  bool get isEvents =>
      widget.collectionPath == "Events";

  bool get isVolunteering =>
      widget.collectionPath ==
      "volunteering";

  bool get isEdit => widget.docId != null;

  @override
  void initState() {
    super.initState();

    loadSkills();
    loadCompanyData();

    if (widget.itemData != null) {
      final data = widget.itemData!;

      // COMMON
      titleController.text =
          data["title"] ??
          data["name"] ??
          "";

      descController.text =
          data["description"] ??
          data["content"] ??
          "";

      existingImageUrl = data["imgUrl"];

      locationController.text =
          data["location"] ?? "";

      selectedType =
          data["type"] ?? "internship";

      selectedCategory =
          data["category"] ?? "Tech";

      // OPPORTUNITIES
      requirementsController.text =
          data["requirements"] ?? "";

      salaryController.text =
          data["salary"]?.toString() ?? "";

      cgpaController.text =
          data["minimumCgpa"]
              ?.toString() ??
          "";

      tagsController.text =
          (data["tags"] as List?)
              ?.join(", ") ??
          "";

      eligibleMajorsController.text =
          (data["eligibleMajors"]
                  as List?)
              ?.join(", ") ??
          "";

      selectedWorkMode =
          data["workMode"] ??
          "Onsite";

      if (data["requiredSkills"] != null) {
        selectedSkills = Set<String>.from(
          data["requiredSkills"],
        );
      }

      if (data["deadline"] != null &&
          data["deadline"]
              is Timestamp) {
        selectedDeadline =
            (data["deadline"]
                    as Timestamp)
                .toDate();
      }

      // POSTS
      selectedVisibility =
          data["visibility"] ??
          "public";

      clubNameController.text =
          data["clubName"] ?? "";

      // USERS
      studentIdController.text =
          data["studentId"] ?? "";

      facultyController.text =
          data["faculty"] ?? "";

      majorController.text =
          data["major"] ?? "";

      minorController.text =
          data["minor"] ?? "";

      academicYearController.text =
          data["academicYear"] ?? "";

      studentCgpaController.text =
          data["cgpa"]?.toString() ??
          "";
    }
  }

  @override
  void dispose() {
    titleController.dispose();

    descController.dispose();

    locationController.dispose();

    requirementsController.dispose();

    salaryController.dispose();

    cgpaController.dispose();

    tagsController.dispose();

    eligibleMajorsController.dispose();

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
    final uid =
        FirebaseAuth
            .instance
            .currentUser
            ?.uid;

    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

    final data = doc.data() ?? {};

    setState(() {
      companyName =
          data['companyName'] ??
          "Company";
    });
  }

  // LOAD SKILLS
  Future<void> loadSkills() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('skills')
            .get();

    setState(() {
      allSkills =
          snapshot.docs
              .map(
                (doc) =>
                    doc['name']
                        .toString(),
              )
              .toList();
    });
  }

  // PICK IMAGE
  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage =
            File(pickedFile.path);
      });
    }
  }

  // PICK DATE
  Future<void> pickDeadline() async {
    final pickedDate =
        await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate:
          selectedDeadline ??
          DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDeadline =
            pickedDate;
      });
    }
  }

  // SAVE ITEM
  Future<void> saveItem() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? imageUrl =
          existingImageUrl;

      // UPLOAD IMAGE
      if (selectedImage != null) {
        final fileName =
            DateTime.now()
                .millisecondsSinceEpoch
                .toString();

        final ref =
            FirebaseStorage.instance
                .ref()
                .child(
                  widget.collectionPath,
                )
                .child(
                  "$fileName.jpg",
                );

        await ref.putFile(
          selectedImage!,
        );

        imageUrl =
            await ref.getDownloadURL();
      }

      final currentUser =
          FirebaseAuth
              .instance
              .currentUser;

      final Map<String, dynamic>
      data = {
        // COMMON
        "imgUrl": imageUrl,

        "updatedAt":
            FieldValue.serverTimestamp(),

        // OPPORTUNITIES
        if (isOpportunities) ...{
          "title":
              titleController.text
                  .trim(),

          "description":
              descController.text
                  .trim(),

          "type": selectedType,

          "providerName":
              companyName,

          "requirements":
              requirementsController
                  .text
                  .trim(),

          "salary":
              salaryController.text
                  .trim(),

          "category":
              selectedCategory,

          "workMode":
              selectedWorkMode,

          "minimumCgpa":
              cgpaController.text
                      .trim()
                      .isEmpty
                  ? null
                  : double.tryParse(
                    cgpaController
                        .text,
                  ),

          "location":
              locationController.text
                  .trim(),

          "requiredSkills":
              selectedSkills
                  .toList(),

          "eligibleMajors":
              eligibleMajorsController
                  .text
                  .split(",")

                  .map(
                    (e) =>
                        e.trim(),
                  )

                  .where(
                    (e) =>
                        e
                            .isNotEmpty,
                  )

                  .toList(),

          "tags":
              tagsController.text
                  .split(",")

                  .map(
                    (e) =>
                        e.trim(),
                  )

                  .where(
                    (e) =>
                        e
                            .isNotEmpty,
                  )

                  .toList(),

          "deadline":
              selectedDeadline ==
                      null
                  ? null
                  : Timestamp.fromDate(
                    selectedDeadline!,
                  ),

          if (!isEdit)
            "status": "pending",

          if (!isEdit)
            "featured": false,
        },

        // POSTS
        if (isPosts) ...{
          "title":
              titleController.text
                  .trim(),

          "content":
              descController.text
                  .trim(),

          "clubName":
              clubNameController.text
                  .trim(),

          "visibility":
              selectedVisibility,
        },

        // USERS
        if (isUsers) ...{
          "name":
              titleController.text
                  .trim(),

          "studentId":
              studentIdController.text
                  .trim(),

          "faculty":
              facultyController.text
                  .trim(),

          "major":
              majorController.text
                  .trim(),

          "minor":
              minorController.text
                  .trim(),

          "academicYear":
              academicYearController
                  .text
                  .trim(),

          "cgpa":
              double.tryParse(
                studentCgpaController
                    .text,
              ),
        },

        // CLUBS
        if (isClubs) ...{
          "name":
              titleController.text
                  .trim(),

          "description":
              descController.text
                  .trim(),
        },

        // EVENTS
        if (isEvents) ...{
          "title":
              titleController.text
                  .trim(),

          "description":
              descController.text
                  .trim(),

          "location":
              locationController.text
                  .trim(),

          "date":
              selectedDeadline ==
                      null
                  ? null
                  : Timestamp.fromDate(
                    selectedDeadline!,
                  ),
        },

        // VOLUNTEERING
        if (isVolunteering) ...{
          "title":
              titleController.text
                  .trim(),

          "description":
              descController.text
                  .trim(),

          "location":
              locationController.text
                  .trim(),

          "deadline":
              selectedDeadline ==
                      null
                  ? null
                  : Timestamp.fromDate(
                    selectedDeadline!,
                  ),
        },

        if (!isEdit)
          "createdAt":
              FieldValue
                  .serverTimestamp(),

        if (!isEdit)
          "createdBy":
              currentUser?.uid,
      };

      // CREATE
      if (!isEdit) {
        await FirebaseFirestore
            .instance
            .collection(
              widget.collectionPath,
            )
            .add(data);
      } else {
        // UPDATE
        await FirebaseFirestore
            .instance
            .collection(
              widget.collectionPath,
            )
            .doc(widget.docId)
            .update(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? "Updated successfully"
                  : "Added successfully",
            ),

            backgroundColor:
                Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    const Color fueRed =
        Color(0xffb1170c);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? "Edit ${widget.collectionPath}"
              : "Add ${widget.collectionPath}",
        ),

        backgroundColor: fueRed,

        foregroundColor:
            Colors.white,
      ),

      body: isLoading
          ? const Center(
            child:
                LoadingIndicator(),
          )
          : Form(
            key: _formKey,

            child:
                SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(
                        16,
                      ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      // IMAGE
                      GestureDetector(
                        onTap:
                            pickImage,

                        child:
                            Container(
                              height:
                                  200,

                              width:
                                  double.infinity,

                              decoration:
                                  BoxDecoration(
                                    color:
                                        Colors
                                            .grey[200],

                                    borderRadius:
                                        BorderRadius.circular(
                                          12,
                                        ),
                                  ),

                              child:
                                  selectedImage !=
                                          null
                                      ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(
                                              12,
                                            ),

                                        child:
                                            kIsWeb
                                                ? Image.network(
                                                  selectedImage!
                                                      .path,

                                                  fit:
                                                      BoxFit.cover,
                                                )
                                                : Image.file(
                                                  selectedImage!,

                                                  fit:
                                                      BoxFit.cover,
                                                ),
                                      )
                                      : existingImageUrl !=
                                                null &&
                                            existingImageUrl!
                                                .isNotEmpty
                                      ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(
                                              12,
                                            ),

                                        child:
                                            Image.network(
                                              existingImageUrl!,

                                              fit:
                                                  BoxFit.cover,
                                            ),
                                      )
                                      : const Icon(
                                        Icons
                                            .add_a_photo,

                                        size:
                                            50,

                                        color:
                                            Colors.grey,
                                      ),
                            ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // TITLE
                      TextFormField(
                        controller:
                            titleController,

                        validator: (
                          value,
                        ) {
                          if (value ==
                                  null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return "Required";
                          }

                          return null;
                        },

                        decoration:
                            InputDecoration(
                              labelText:
                                  isUsers
                                      ? "Student Name"
                                      : isClubs
                                      ? "Club Name"
                                      : "Title",

                              border:
                                  const OutlineInputBorder(),
                            ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // DESCRIPTION
                      TextFormField(
                        controller:
                            descController,

                        maxLines: 4,

                        decoration:
                            InputDecoration(
                              labelText:
                                  isPosts
                                      ? "Content"
                                      : "Description",

                              border:
                                  const OutlineInputBorder(),
                            ),
                      ),

                      // OPPORTUNITIES
                      if (isOpportunities) ...[
                        const SizedBox(
                          height: 15,
                        ),

                        DropdownButtonFormField<
                          String
                        >(
                          value:
                              selectedType,

                          decoration:
                              const InputDecoration(
                                labelText:
                                    "Type",

                                border:
                                    OutlineInputBorder(),
                              ),

                          items:
                              const [
                                DropdownMenuItem(
                                  value:
                                      "internship",

                                  child:
                                      Text(
                                        "Internship",
                                      ),
                                ),

                                DropdownMenuItem(
                                  value:
                                      "job",

                                  child:
                                      Text(
                                        "Job",
                                      ),
                                ),
                              ],

                          onChanged: (
                            value,
                          ) {
                            setState(() {
                              selectedType =
                                  value!;
                            });
                          },
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        DropdownButtonFormField<
                          String
                        >(
                          value:
                              selectedCategory,

                          decoration:
                              const InputDecoration(
                                labelText:
                                    "Category",

                                border:
                                    OutlineInputBorder(),
                              ),

                          items:
                              categories.map((
                                cat,
                              ) {
                                return DropdownMenuItem(
                                  value:
                                      cat,

                                  child:
                                      Text(
                                        cat,
                                      ),
                                );
                              }).toList(),

                          onChanged: (
                            value,
                          ) {
                            setState(() {
                              selectedCategory =
                                  value!;
                            });
                          },
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        DropdownButtonFormField<
                          String
                        >(
                          value:
                              selectedWorkMode,

                          decoration:
                              const InputDecoration(
                                labelText:
                                    "Work Mode",

                                border:
                                    OutlineInputBorder(),
                              ),

                          items:
                              const [
                                DropdownMenuItem(
                                  value:
                                      "Onsite",

                                  child:
                                      Text(
                                        "Onsite",
                                      ),
                                ),

                                DropdownMenuItem(
                                  value:
                                      "Remote",

                                  child:
                                      Text(
                                        "Remote",
                                      ),
                                ),

                                DropdownMenuItem(
                                  value:
                                      "Hybrid",

                                  child:
                                      Text(
                                        "Hybrid",
                                      ),
                                ),
                              ],

                          onChanged: (
                            value,
                          ) {
                            setState(() {
                              selectedWorkMode =
                                  value!;
                            });
                          },
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        TextFormField(
                          controller:
                              requirementsController,

                          maxLines: 4,

                          decoration:
                              const InputDecoration(
                                labelText:
                                    "Requirements",

                                border:
                                    OutlineInputBorder(),
                              ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        TextFormField(
                          controller:
                              cgpaController,

                          keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal:
                                    true,
                              ),

                          decoration:
                              const InputDecoration(
                                labelText:
                                    "Minimum CGPA",

                                border:
                                    OutlineInputBorder(),
                              ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        TextFormField(
                          controller:
                              eligibleMajorsController,

                          decoration:
                              const InputDecoration(
                                labelText:
                                    "Eligible Majors (comma separated)",

                                hintText:
                                    "Computer Science, BIS",

                                border:
                                    OutlineInputBorder(),
                              ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        TextFormField(
                          controller:
                              salaryController,

                          decoration:
                              const InputDecoration(
                                labelText:
                                    "Salary / Stipend",

                                border:
                                    OutlineInputBorder(),
                              ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        TextFormField(
                          controller:
                              locationController,

                          decoration:
                              const InputDecoration(
                                labelText:
                                    "Location",

                                border:
                                    OutlineInputBorder(),
                              ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        GestureDetector(
                          onTap:
                              pickDeadline,

                          child:
                              Container(
                                width:
                                    double.infinity,

                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal:
                                          12,

                                      vertical:
                                          16,
                                    ),

                                decoration:
                                    BoxDecoration(
                                      border:
                                          Border.all(
                                            color:
                                                Colors.grey,
                                          ),

                                      borderRadius:
                                          BorderRadius.circular(
                                            4,
                                          ),
                                    ),

                                child:
                                    Text(
                                      selectedDeadline ==
                                              null
                                          ? "Select Deadline"
                                          : "${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}",
                                    ),
                              ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        const Text(
                          "Required Skills",

                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,

                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Wrap(
                          spacing: 8,

                          runSpacing:
                              8,

                          children:
                              allSkills.map((
                                skill,
                              ) {
                                final isSelected =
                                    selectedSkills.contains(
                                      skill,
                                    );

                                return FilterChip(
                                  label:
                                      Text(
                                        skill,
                                      ),

                                  selected:
                                      isSelected,

                                  onSelected: (
                                    value,
                                  ) {
                                    setState(() {
                                      if (value) {
                                        selectedSkills.add(
                                          skill,
                                        );
                                      } else {
                                        selectedSkills.remove(
                                          skill,
                                        );
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        TextFormField(
                          controller:
                              tagsController,

                          decoration:
                              const InputDecoration(
                                labelText:
                                    "Tags / Interests",

                                hintText:
                                    "frontend, mobile, AI",

                                border:
                                    OutlineInputBorder(),
                              ),
                        ),
                      ],

                      const SizedBox(
                        height: 30,
                      ),

                      // SAVE
                      SizedBox(
                        width:
                            double.infinity,

                        height: 52,

                        child:
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    fueRed,
                              ),

                              onPressed:
                                  saveItem,

                              child:
                                  Text(
                                    isEdit
                                        ? "UPDATE"
                                        : "SAVE",

                                    style:
                                        const TextStyle(
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
          ),
    );
  }
}