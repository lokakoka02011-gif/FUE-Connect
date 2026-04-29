import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FormsPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const FormsPage({super.key, required this.data});

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cvController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();

  bool _isSubmitting = false;

  // 🔥 NEW: skills system
  List<String> selectedSkills = [];
  List<String> allSkills = [];

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    final snapshot = await FirebaseFirestore.instance.collection('skills').get();
    setState(() {
      allSkills = snapshot.docs.map((doc) => doc['name'].toString()).toList();
    });
  }

  void _openSkillSelector() {
    List<String> tempSelected = List.from(selectedSkills);

    showDialog(
      context: context,
      builder: (context) {
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
                    setState(() {
                      if (value == true) {
                        tempSelected.add(skill);
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
                  selectedSkills = tempSelected;
                });
                Navigator.pop(context);
              },
              child: const Text("Done"),
            )
          ],
        );
      },
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('Application').add({
        'userId': user!.uid,
        'title': widget.data['Title'] ?? '',
        'category': widget.data['Type'] == 'job' ? 'Jobs' : 'Internships',
        'organization': widget.data['Company'] ?? 'Unknown',

        // 🔥 new form data
        'cvLink': _cvController.text,
        'motivation': _motivationController.text,
        'skills': selectedSkills,

        'status': 'Pending',
        'date': DateTime.now().toString(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Application submitted successfully ✅"),
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
      if (mounted) setState(() => _isSubmitting = false);
    }
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

                _buildTextField(_cvController, "CV Link (Google Drive)", Icons.link),
                _buildTextField(_motivationController, "Why are you applying?", Icons.edit, maxLines: 4),

                const SizedBox(height: 15),

                // 🔥 SKILLS SELECTOR
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text("Skills", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),

                GestureDetector(
                  onTap: _openSkillSelector,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      selectedSkills.isEmpty
                          ? "Select skills"
                          : selectedSkills.join(", "),
                      style: TextStyle(
                        color: selectedSkills.isEmpty ? Colors.grey : Colors.black,
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
                      backgroundColor: const Color(0xffb1170c),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitApplication,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Submit Application",
                            style: TextStyle(color: Colors.white),
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
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? "Field required" : null,
      ),
    );
  }
}
