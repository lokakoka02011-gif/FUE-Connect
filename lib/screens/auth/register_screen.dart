import 'package:flutter/material.dart';
import 'package:fue_connect/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final AuthService _authService =
      AuthService();

  final _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _emailController =
          TextEditingController();

  final TextEditingController
      _passwordController =
          TextEditingController();

  final TextEditingController
      _confirmPasswordController =
          TextEditingController();

  final TextEditingController
      _firstNameController =
          TextEditingController();

  final TextEditingController
      _lastNameController =
          TextEditingController();

  bool _isLoading = false;

  bool _obscurePassword = true;

  bool _obscureConfirmPassword =
      true;

  @override
  void dispose() {

    _emailController.dispose();

    _passwordController.dispose();

    _confirmPasswordController
        .dispose();

    _firstNameController.dispose();

    _lastNameController.dispose();

    super.dispose();
  }

  Future<void> _register() async {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_passwordController.text !=
        _confirmPasswordController
            .text) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Passwords do not match!",
          ),
        ),
      );

      return;
    }

    setState(() {

      _isLoading = true;
    });

    final String fullEmail =
        _emailController.text.trim();

    final emailParts =
        fullEmail.split('@');

    final username =
        emailParts.first;

    final domain =
        emailParts.length > 1
            ? emailParts.last
            : "";

    String userRole;

    // ROLE RULES
    // fue.edu.eg + 8 digits = student
    // fue.edu.eg + not 8 digits = admin
    // anything else = company

    if (domain == "fue.edu.eg") {

      final bool isStudent =
          RegExp(r'^\d{8}$')
              .hasMatch(username);

      userRole =
          isStudent
              ? "student"
              : "admin";

    } else {

      userRole = "company";
    }

    // CUSTOM ID
    String prefix;

    if (userRole == "student") {

      prefix = "s";

    } else if (userRole ==
        "admin") {

      prefix = "a";

    } else {

      prefix = "c";
    }

    final randomNumber =
        DateTime.now()
            .millisecondsSinceEpoch
            .toString()
            .substring(7, 13);

    final customId =
        "$prefix$randomNumber";

    try {

      // CREATE FIREBASE AUTH USER
      await _authService
          .registerWithEmail(

        email: fullEmail,

        password:
            _passwordController.text,

        firstName:
            _firstNameController.text
                .trim(),

        lastName:
            _lastNameController.text
                .trim(),

        role: userRole,
      );

      User? user =
          FirebaseAuth
              .instance
              .currentUser;

      if (user != null) {

        // IMPORTANT:
        // FIREBASE UID stays document ID

        await FirebaseFirestore
            .instance
            .collection('users')
            .doc(user.uid)
            .set({

          // CUSTOM DISPLAY ID
          'customId': customId,

          // FIREBASE UID
          'uid': user.uid,

          // STUDENT ID ONLY
          'studentId':

              userRole == "student"

                  ? username

                  : null,

          // BASIC INFO
          'email': fullEmail,

          'firstName':
              _firstNameController
                  .text
                  .trim(),

          'lastName':
              _lastNameController
                  .text
                  .trim(),

          'fullName':

              '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',

          // ROLE
          'role': userRole,

          // STUDENT DATA
          'faculty': null,
          'major': null,
          'minor': null,
          'cgpa': null,

          // COMPANY DATA
          'companyName': null,
          'companyDescription':
              null,
          'companyWebsite':
              null,
          'companyLocation':
              null,

          'companyProfileCompleted':
              false,

          // APPROVAL SYSTEM
          'approvalStatus':

              userRole == "company"

                  ? "pending"

                  : "approved",

          // GENERAL
          'profileCompleted':
              false,

          'createdAt':
              FieldValue
                  .serverTimestamp(),

          'updatedAt':
              FieldValue
                  .serverTimestamp(),
        });

        // SEND EMAIL VERIFICATION
        if (!user.emailVerified) {

          await user
              .sendEmailVerification();
        }

        if (mounted) {

          _showSuccessDialog(
            fullEmail,
          );
        }
      }

    } on FirebaseAuthException catch (e) {

      String message =
          "Registration failed.";

      if (e.code ==
          'weak-password') {

        message =
            "Password is too weak.";

      } else if (e.code ==
          'email-already-in-use') {

        message =
            "This email is already registered.";

      } else if (e.code ==
          'invalid-email') {

        message =
            "The email address is not valid.";
      }

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(
            content:
                Text(message),

            backgroundColor:
                Colors.red,
          ),
        );
      }

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(
            content:
                Text("Error: $e"),

            backgroundColor:
                Colors.red,
          ),
        );
      }

    } finally {

      if (mounted) {

        setState(() {

          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(
      String email) {

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context) =>
          AlertDialog(

        title:
            const Text("Verify Email"),

        content: Text(

          "A verification link was sent to:\n\n$email\n\nPlease verify your email before logging in.",
        ),

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

      appBar: AppBar(
        title:
            const Text("Create Account"),
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(24),

          child: Form(

            key: _formKey,

            child: Column(

              children: [

                const Icon(
                  Icons.person_add,
                  size: 60,
                  color:
                      Color(0xffb1170c),
                ),

                const SizedBox(
                  height: 20,
                ),

                TextFormField(

                  controller:
                      _firstNameController,

                  decoration:
                      const InputDecoration(

                    labelText:
                        "First Name",

                    border:
                        OutlineInputBorder(),
                  ),

                  validator: (v) {

                    if (v == null ||
                        v.trim().isEmpty) {

                      return
                          "Enter your first name";
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 16,
                ),

                TextFormField(

                  controller:
                      _lastNameController,

                  decoration:
                      const InputDecoration(

                    labelText:
                        "Last Name",

                    border:
                        OutlineInputBorder(),
                  ),

                  validator: (v) {

                    if (v == null ||
                        v.trim().isEmpty) {

                      return
                          "Enter your last name";
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 16,
                ),

                Column(

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    TextFormField(

                      controller:
                          _emailController,

                      decoration:
                          const InputDecoration(

                        labelText:
                            "Email",

                        hintText:
                            "Enter your email",

                        border:
                            OutlineInputBorder(),
                      ),

                      validator: (v) {

                        if (v == null ||
                            v.trim().isEmpty) {

                          return
                              "Enter your email";
                        }

                        if (!v.contains('@')) {

                          return
                              "Invalid email";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Wrap(

                      spacing: 8,

                      children: [

                        ActionChip(

                          label:
                              const Text(
                            "@fue.edu.eg",
                          ),

                          onPressed: () {

                            final current =
                                _emailController
                                    .text
                                    .trim();

                            if (!current
                                .contains('@')) {

                              setState(() {

                                _emailController
                                    .text =
                                    "$current@fue.edu.eg";
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),

                TextFormField(

                  controller:
                      _passwordController,

                  obscureText:
                      _obscurePassword,

                  decoration:
                      InputDecoration(

                    labelText:
                        "Password",

                    helperText:
                        "8+ chars, uppercase, number, special character",

                    border:
                        const OutlineInputBorder(),

                    suffixIcon:
                        IconButton(

                      icon: Icon(

                        _obscurePassword

                            ? Icons.visibility

                            : Icons.visibility_off,
                      ),

                      onPressed: () {

                        setState(() {

                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  validator: (v) {

                    if (v == null ||
                        v.length < 8) {

                      return
                          "Must be at least 8 characters";
                    }

                    if (!RegExp(

                      r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~])',

                    ).hasMatch(v)) {

                      return
                          "Need uppercase, number, and symbol";
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 16,
                ),

                TextFormField(

                  controller:
                      _confirmPasswordController,

                  obscureText:
                      _obscureConfirmPassword,

                  decoration:
                      InputDecoration(

                    labelText:
                        "Confirm Password",

                    border:
                        const OutlineInputBorder(),

                    suffixIcon:
                        IconButton(

                      icon: Icon(

                        _obscureConfirmPassword

                            ? Icons.visibility

                            : Icons.visibility_off,
                      ),

                      onPressed: () {

                        setState(() {

                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),

                  validator: (v) {

                    if (v == null ||
                        v.isEmpty) {

                      return
                          "Confirm your password";
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 30,
                ),

                SizedBox(

                  width:
                      double.infinity,

                  height: 50,

                  child: ElevatedButton(

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          const Color(
                        0xffb1170c,
                      ),
                    ),

                    onPressed:

                        _isLoading

                            ? null

                            : _register,

                    child: _isLoading

                        ? const LoadingIndicator()

                        : const Text(

                            "Register",

                            style:
                                TextStyle(

                              color:
                                  Colors.white,

                              fontSize: 16,
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
}