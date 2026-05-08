import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController requirementsController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController locationController = TextEditingController();


  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.itemData != null) {
      titleController.text = widget.itemData!["title"] ?? "";
      descController.text = widget.itemData!["description"] ?? "";
      _existingImageUrl = widget.itemData!["imageUrl"];
      requirementsController.text = widget.itemData!["requirements"] ?? "";
      deadlineController.text = widget.itemData!["deadline"] ?? "";
      locationController.text = widget.itemData!["location"] ?? "";      
    }
  }


    @override
    void dispose() {
      titleController.dispose();
      descController.dispose();
      requirementsController.dispose();
      deadlineController.dispose();
      locationController.dispose();
      super.dispose();
    }


  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> saveItem() async {
      if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _existingImageUrl;

// upload new image only law user selected one
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('admin_uploads')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        
        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      final data = {
        "title": titleController.text,
        "description": descController.text,
        "requirements": requirementsController.text,
        "deadline": deadlineController.text,
        "location": locationController.text,
        "imageUrl": imageUrl,
        "updatedAt": FieldValue.serverTimestamp(),
      };

// save to firestore. if no docId create new, gher keda update existing
      if (widget.docId == null) {
        data["createdAt"] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection(widget.collectionPath)
            .add(data);
      } else {
        await FirebaseFirestore.instance.collection(widget.collectionPath).doc(widget.docId).update(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Saved successfully"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
        if (mounted) {
        setState(() => _isLoading = false);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color fueRed = Color(0xffb1170c);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docId == null ? "Add ${widget.collectionPath}" : "Edit Item"),
        backgroundColor: fueRed,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: fueRed))
        : Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  
                const SizedBox(height: 15),                
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_selectedImage!, fit: BoxFit.cover))
                        : (_existingImageUrl != null 
                            ? ClipRRect(borderRadius: BorderRadius.circular(10), 
                            child:Image.network(
                                _existingImageUrl!, 
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                    );
                                },
                                ))
                            : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Title is required";
                    }
                    return null;
                  },                  
                  decoration: const InputDecoration(
                    labelText: "Title", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: descController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Description is required";
                    }
                    return null;
                  },                  
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: requirementsController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Requirements are required";
                    }
                    return null;
                  },                  
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Requirements",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: deadlineController,
                  decoration: const InputDecoration(
                    labelText: "Deadline",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: "Location",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: fueRed),
                    onPressed: saveItem,
                    child: const Text("SAVE TO DATABASE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}