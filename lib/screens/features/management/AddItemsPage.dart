import 'dart:io';

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

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController descController =
      TextEditingController();

  final TextEditingController requirementsController =
      TextEditingController();

  final TextEditingController salaryController =
      TextEditingController();

  final TextEditingController locationController =
      TextEditingController();

  final TextEditingController cgpaController =
      TextEditingController();

  String selectedType = "internship";

  String selectedCategory = "Tech";

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

  @override
  void initState() {
    super.initState();

    loadSkills();
    loadCompanyData();

    if (widget.itemData != null) {

      final data = widget.itemData!;

      titleController.text =
          data["title"] ?? "";

      descController.text =
          data["description"] ?? "";

      requirementsController.text =
          data["requirements"] ?? "";

      salaryController.text =
          data["salary"]?.toString() ?? "";

      locationController.text =
          data["location"] ?? "";

      cgpaController.text =
          data["minimumCgpa"]?.toString() ?? "";

      selectedType =
          data["type"] ?? "internship";

      selectedCategory =
          data["category"] ?? "Tech";

      existingImageUrl =
          data["imageUrl"];

      if (data["requiredSkills"] != null) {

        selectedSkills =
            Set<String>.from(
              data["requiredSkills"],
            );
      }

      if (data["deadline"] != null &&
          data["deadline"] is Timestamp) {

        selectedDeadline =
            (data["deadline"] as Timestamp)
                .toDate();
      }
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

    super.dispose();
  }

  Future<void> loadCompanyData() async {

    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

    final data = doc.data() ?? {};

    setState(() {

      companyName =
          data['companyName'] ?? "Company";
    });
  }

  Future<void> loadSkills() async {

    final snapshot =
        await FirebaseFirestore.instance
            .collection('skills')
            .get();

    setState(() {

      allSkills = snapshot.docs
          .map((doc) => doc['name'].toString())
          .toList();
    });
  }

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

        selectedDeadline = pickedDate;
      });
    }
  }

  Future<void> saveItem() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDeadline == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text("Select deadline"),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      String? imageUrl =
          existingImageUrl;

      if (selectedImage != null) {

        final ref =
            FirebaseStorage.instance
                .ref()
                .child('opportunities')
                .child(
                  '${DateTime.now().millisecondsSinceEpoch}.jpg',
                );

        await ref.putFile(selectedImage!);

        imageUrl =
            await ref.getDownloadURL();
      }

      final currentUser =
          FirebaseAuth.instance.currentUser;

      final data = {

        "title":
            titleController.text.trim(),

        "description":
            descController.text.trim(),

        "type":
            selectedType,

        "providerName":
            companyName,

        "deadline":
            Timestamp.fromDate(
              selectedDeadline!,
            ),

        "requirements":
            requirementsController.text
                .trim(),

        "salary":
            int.tryParse(
                  salaryController.text,
                ) ??
                0,

        "category":
            selectedCategory,

        "minimumCgpa":
            cgpaController.text.trim().isEmpty
                ? null
                : double.tryParse(
                    cgpaController.text,
                  ),

        "imageUrl":
            imageUrl,

        "location":
            locationController.text.trim(),

        "requiredSkills":
            selectedSkills.toList(),

        "applicationCount":
            0,

        if (widget.docId == null)
          "status": "pending",

        "featured":
            false,

        "createdBy":
            currentUser?.uid,

        "updatedAt":
            FieldValue.serverTimestamp(),
      };

      if (widget.docId == null) {

        data["createdAt"] =
            FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection(widget.collectionPath)
            .add(data);

      } else {

        await FirebaseFirestore.instance
            .collection(widget.collectionPath)
            .doc(widget.docId)
            .update(data);
      }

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content:
                Text("Saved successfully"),
            backgroundColor:
                Colors.green,
          ),
        );

        Navigator.pop(context);
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text("Error: $e"),
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
  Widget build(BuildContext context) {

    const Color fueRed =
        Color(0xffb1170c);

    return Scaffold(

      appBar: AppBar(
        title: Text(
          widget.docId == null
              ? "Add Opportunity"
              : "Edit Opportunity",
        ),

        backgroundColor: fueRed,
        foregroundColor: Colors.white,
      ),

      body: isLoading

          ? const Center(
              child: LoadingIndicator(),
            )

          : Form(
              key: _formKey,

              child: SingleChildScrollView(

                padding:
                    const EdgeInsets.all(16),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    GestureDetector(

                      onTap: pickImage,

                      child: Container(

                        height: 200,
                        width: double.infinity,

                        decoration: BoxDecoration(
                          color: Colors.grey[200],

                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),

                        child: selectedImage != null

                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),

                                child: Image.file(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )

                            : existingImageUrl != null

                                ? ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(
                                      12,
                                    ),

                                    child:
                                        Image.network(
                                      existingImageUrl!,
                                      fit: BoxFit.cover,
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

                    TextFormField(
                      controller: titleController,

                      validator: (value) =>
                          value == null ||
                                  value.trim().isEmpty
                              ? "Required"
                              : null,

                      decoration:
                          const InputDecoration(
                        labelText: "Title",
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: descController,

                      maxLines: 4,

                      validator: (value) =>
                          value == null ||
                                  value.trim().isEmpty
                              ? "Required"
                              : null,

                      decoration:
                          const InputDecoration(
                        labelText:
                            "Description",
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(

                      value: selectedType,

                      decoration:
                          const InputDecoration(
                        labelText: "Type",
                        border:
                            OutlineInputBorder(),
                      ),

                      items: const [

                        DropdownMenuItem(
                          value: "internship",
                          child: Text(
                            "Internship",
                          ),
                        ),

                        DropdownMenuItem(
                          value: "job",
                          child: Text(
                            "Job",
                          ),
                        ),
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

                      decoration:
                          const InputDecoration(
                        labelText:
                            "Category",
                        border:
                            OutlineInputBorder(),
                      ),

                      items:
                          categories.map((cat) {

                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),

                      onChanged: (value) {

                        setState(() {

                          selectedCategory =
                              value!;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller:
                          salaryController,

                      keyboardType:
                          TextInputType.number,

                      decoration:
                          const InputDecoration(
                        labelText:
                            "Salary (EGP)",
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller:
                          cgpaController,

                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      decoration:
                          const InputDecoration(
                        labelText:
                            "Minimum CGPA",
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller:
                          requirementsController,

                      maxLines: 3,

                      decoration:
                          const InputDecoration(
                        labelText:
                            "Requirements",
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Required Skills",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,

                      children:
                          allSkills.map((skill) {

                        final isSelected =
                            selectedSkills
                                .contains(skill);

                        return GestureDetector(

                          onTap: () {

                            setState(() {

                              if (isSelected) {

                                selectedSkills
                                    .remove(skill);

                              } else {

                                selectedSkills
                                    .add(skill);
                              }
                            });
                          },

                          child: Container(

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              color: isSelected
                                  ? fueRed
                                  : Colors.grey[200],

                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                            ),

                            child: Text(
                              skill,

                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

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

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,

                      child: OutlinedButton.icon(

                        onPressed:
                            pickDeadline,

                        icon: const Icon(
                          Icons.calendar_today,
                        ),

                        label: Text(

                          selectedDeadline == null

                              ? "Select Deadline"

                              : "${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}",
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(

                      width: double.infinity,
                      height: 52,

                      child: ElevatedButton(

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              fueRed,
                        ),

                        onPressed:
                            saveItem,

                        child: const Text(
                          "SAVE OPPORTUNITY",

                          style: TextStyle(
                            color: Colors.white,
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