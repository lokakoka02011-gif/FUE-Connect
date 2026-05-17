import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;

  // SHOW / HIDE PASSWORDS
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  // PASSWORD RULE CHECKER
  bool hasUppercase(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  bool hasLowercase(String password) {
    return password.contains(RegExp(r'[a-z]'));
  }

  bool hasNumber(String password) {
    return password.contains(RegExp(r'[0-9]'));
  }

  bool hasSpecialCharacter(String password) {
    return password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  // CHANGE PASSWORD FUNCTION
  void showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();

    final newPasswordController = TextEditingController();

    final confirmPasswordController = TextEditingController();

    bool isLoading = false;

    showDialog(
      context: context,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Change Password"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // CURRENT PASSWORD
                    TextField(
                      controller: currentPasswordController,

                      obscureText: !showCurrentPassword,

                      decoration: InputDecoration(
                        labelText: "Current Password",

                        border: const OutlineInputBorder(),

                        suffixIcon: IconButton(
                          icon: Icon(
                            showCurrentPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),

                          onPressed: () {
                            setState(() {
                              showCurrentPassword = !showCurrentPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // NEW PASSWORD
                    TextField(
                      controller: newPasswordController,

                      obscureText: !showNewPassword,

                      onChanged: (value) {
                        setDialogState(() {});
                      },

                      decoration: InputDecoration(
                        labelText: "New Password",

                        border: const OutlineInputBorder(),

                        suffixIcon: IconButton(
                          icon: Icon(
                            showNewPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),

                          onPressed: () {
                            setState(() {
                              showNewPassword = !showNewPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // CONFIRM PASSWORD
                    TextField(
                      controller: confirmPasswordController,

                      obscureText: !showConfirmPassword,

                      decoration: InputDecoration(
                        labelText: "Confirm New Password",

                        border: const OutlineInputBorder(),

                        suffixIcon: IconButton(
                          icon: Icon(
                            showConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),

                          onPressed: () {
                            setState(() {
                              showConfirmPassword = !showConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // PASSWORD RULES
                    const Text(
                      "Password must contain:",

                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    _passwordRule(
                      "At least 8 characters",
                      newPasswordController.text.length >= 8,
                    ),

                    _passwordRule(
                      "One uppercase letter",
                      hasUppercase(newPasswordController.text),
                    ),

                    _passwordRule(
                      "One lowercase letter",
                      hasLowercase(newPasswordController.text),
                    ),

                    _passwordRule(
                      "One number",
                      hasNumber(newPasswordController.text),
                    ),

                    _passwordRule(
                      "One special character",
                      hasSpecialCharacter(newPasswordController.text),
                    ),
                  ],
                ),
              ),

              actions: [
                // CANCEL BUTTON
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text("Cancel"),
                ),

                // UPDATE BUTTON
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          // EMPTY CHECK
                          if (currentPasswordController.text.trim().isEmpty ||
                              newPasswordController.text.trim().isEmpty ||
                              confirmPasswordController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill all fields"),
                              ),
                            );

                            return;
                          }

                          // PASSWORD RULES
                          String password = newPasswordController.text.trim();

                          if (password.length < 8 ||
                              !hasUppercase(password) ||
                              !hasLowercase(password) ||
                              !hasNumber(password) ||
                              !hasSpecialCharacter(password)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Password does not meet security requirements",
                                ),
                              ),
                            );

                            return;
                          }

                          // MATCH CHECK
                          if (newPasswordController.text.trim() !=
                              confirmPasswordController.text.trim()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Passwords do not match"),
                              ),
                            );

                            return;
                          }

                          try {
                            setDialogState(() {
                              isLoading = true;
                            });

                            User? user = FirebaseAuth.instance.currentUser;

                            if (user != null && user.email != null) {
                              // REAUTHENTICATE
                              AuthCredential credential =
                                  EmailAuthProvider.credential(
                                    email: user.email!,

                                    password: currentPasswordController.text
                                        .trim(),
                                  );

                              await user.reauthenticateWithCredential(
                                credential,
                              );

                              // UPDATE PASSWORD
                              await user.updatePassword(
                                newPasswordController.text.trim(),
                              );

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Password updated successfully",
                                  ),
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            String message = "Something went wrong";

                            if (e.code == 'wrong-password') {
                              message = "Current password is incorrect";
                            } else if (e.code == 'requires-recent-login') {
                              message = "Please login again and retry";
                            }

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          } finally {
                            setDialogState(() {
                              isLoading = false;
                            });
                          }
                        },

                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,

                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // PASSWORD RULE WIDGET
  Widget _passwordRule(String text, bool passed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),

      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,

            color: passed ? Colors.green : Colors.red,

            size: 18,
          ),

          const SizedBox(width: 8),

          Text(text),
        ],
      ),
    );
  }

  // ABOUT APP
  void showAboutDialogBox() {
    showDialog(
      context: context,

      builder: (_) => const AlertDialog(
        title: Text("FUE Connect"),

        content: Text(
          "Version 1.0\n\n"
          "A platform for FUE students.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),

      body: ListView(
        children: [
          // NOTIFICATIONS
          SwitchListTile(
            title: const Text("Notifications"),

            subtitle: const Text("Receive app notifications"),

            value: notificationsEnabled,

            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),

          const Divider(),

          // CHANGE PASSWORD
          ListTile(
            leading: const Icon(Icons.lock),

            title: const Text("Change Password"),

            trailing: const Icon(Icons.arrow_forward_ios),

            onTap: () {
              showChangePasswordDialog();
            },
          ),

          // ABOUT APP
          ListTile(
            leading: const Icon(Icons.info),

            title: const Text("About App"),

            trailing: const Icon(Icons.arrow_forward_ios),

            onTap: () {
              showAboutDialogBox();
            },
          ),
        ],
      ),
    );
  }
}
