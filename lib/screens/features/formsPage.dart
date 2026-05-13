import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';

class FormsPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const FormsPage({
    super.key,
    required this.data,
  });

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cvController = TextEditingController();
  final TextEditingController _motivationController =
      TextEditingController();

  bool _isSubmitting = false;

  bool get isClubForm => widget.data['type'] == 'club';

  List<String> selectedSkills = [];
  List<String> allSkills = [];

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

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

  void _openSkillSelector() {
    List<String> tempSelected = List.from(selectedSkills);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Select Skills"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  children: allSkills.map((skill) {
                    return CheckboxListTile(
                      title: Text(skill),
                      value: tempSelected.contains(skill),
                      onChanged: (value) {
                        setStateDialog(() {
                          if (value == true) {
                            if (!tempSelected.contains(skill)) {
                              tempSelected.add(skill);
                            }
                          } else {
                            tempSelected.remove(skill);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedSkills =
                          tempSelected.toSet().toList();
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userName = userDoc.data()?['name'] ?? '';
      final studentId = userDoc.data()?['studentId'] ?? '';
      final email = user.email ?? '';

      await FirebaseFirestore.instance
          .collection('applications')
          .add({
        'userId': user.uid,
        'companyId': widget.data['createdBy'] ?? '',
        'userName': userName,
        'studentId': studentId,
        'email': email,
        'opportunityId': widget.data['id'] ?? '',
        'title': widget.data['Title'] ?? '',
        'organization':
            widget.data['Company'] ?? 'Unknown',
        'cvUrl': _cvController.text,
        'motivation': _motivationController.text,
        'skills': selectedSkills.toSet().toList(),
        'status': 'pending',
        'submissionDate':
            FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Application submitted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _pickFile() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "File upload temporarily disabled",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Application Form"),
        backgroundColor: const Color(0xffb1170c),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Apply for: ${widget.data['Title'] ?? ''}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffb1170c),
                  ),
                ),

                const SizedBox(height: 20),

                if (!isClubForm)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        _cvController.text.isEmpty
                            ? "Upload CV"
                            : _cvController.text,
                      ),
                    ),
                  ),

                const SizedBox(height: 15),

                _buildTextField(
                  _motivationController,
                  "Why are you applying?",
                  Icons.edit,
                  maxLines: 4,
                ),

                const SizedBox(height: 15),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Skills",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                GestureDetector(
                  onTap: _openSkillSelector,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Text(
                      selectedSkills.isEmpty
                          ? "Select skills"
                          : selectedSkills.join(", "),
                      style: TextStyle(
                        color: selectedSkills.isEmpty
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xffb1170c),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : _submitApplication,
                    child: _isSubmitting
                        ? const LoadingIndicator()
                        : const Text(
                            "Submit Application",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? TextInputType.number
            : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Field required";
          }
          return null;
        },
      ),
    );
  }
}