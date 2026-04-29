import 'package:flutter/material.dart';
import 'package:fue_connect/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ ADDED

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String input = _emailController.text.trim();
    final String fullEmail = "$input@fue.edu.eg";

    final bool isStudent = RegExp(r'^\d{8}$').hasMatch(input);
    final String userRole = isStudent ? "student" : "admin";

    try {
      // ✅ Firebase Auth (your existing service)
      await _authService.registerWithEmail(
        email: fullEmail,
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        role: userRole,
      );

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // ✅ Document ID logic
        String docId = isStudent ? input : "admin_${user.uid}";

        // ✅ Save in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .set({
          'email': fullEmail,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'role': userRole,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // ✅ Email verification (unchanged)
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      if (mounted) _showSuccessDialog(fullEmail);

    } on FirebaseAuthException catch (e) {
      String message = e.code == 'email-already-in-use'
          ? "This email is already registered."
          : "Registration failed.";

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Verify Email"),
        content: Text("A link has been sent to $email. Please verify before logging in."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.person_add, size: 60, color: Color(0xffb1170c)),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (v) => _firstNameController.value = _firstNameController.value.copyWith(
                    text: _capitalize(v),
                    selection: TextSelection.collapsed(offset: _capitalize(v).length),
                  ),
                  decoration: const InputDecoration(labelText: "First Name", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (v) => _lastNameController.value = _lastNameController.value.copyWith(
                    text: _capitalize(v),
                    selection: TextSelection.collapsed(offset: _capitalize(v).length),
                  ),
                  decoration: const InputDecoration(labelText: "Last Name", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "University Email",
                    hintText: "e.g. 20250001",
                    suffixText: "@fue.edu.eg",
                    suffixStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    border: OutlineInputBorder()
                  ),
                  validator: (v) => v!.isEmpty ? "Enter your ID or Email" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    helperText: "8+ chars, 1 uppercase, 1 number",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 8) return "Must be 8+ characters";
                    if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9])').hasMatch(v)) return "Need 1 uppercase & 1 number";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? "Confirm your password" : null,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffb1170c)),
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Register", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
