import 'package:flutter/material.dart';
import 'package:fue_connect/services/auth_service.dart';
import 'package:fue_connect/screens/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final Color fueRed = const Color(0xffb1170c);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // 1. Convert ID to lowercase and trim spaces for case-insensitivity
    final idInput = _emailController.text.trim().toLowerCase();
    final fullEmail = "$idInput@fue.edu.eg";

    try {
      await _authService.loginWithEmail(
        email: fullEmail,
        password: _passwordController.text,
      );

      if (mounted) {
        bool isStudent = RegExp(r'^\d{8}$').hasMatch(idInput);
        
        if (isStudent) {
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        // Display generic error for both wrong email and wrong password
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Wrong password or email. Please try again."), 
            backgroundColor: Colors.red
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your ID first")),
      );
      return;
    }
    try {
      // Apply lowercase logic to reset as well
      final fullEmail = "${_emailController.text.trim().toLowerCase()}@fue.edu.eg";
      await _authService.sendPasswordReset(fullEmail);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reset link sent to your FUE mail"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onLongPress: () => Navigator.pushNamed(context, '/admin_login'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: fueRed.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.school_rounded, size: 80, color: fueRed),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('FUE CONNECT', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: fueRed)),
                  const Text('Login to your account', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 40),

                  // ID Field with Locked Domain and Badge Icon
                  TextFormField(
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                    autocorrect: false, // Prevents ID being changed by phone
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      labelText: 'ID', // Only ID
                      prefixIcon: Icon(Icons.badge_outlined, color: fueRed),
                      suffixText: "@fue.edu.eg", 
                      suffixStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v!.isEmpty ? 'Enter your ID' : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline, color: fueRed),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? 'Enter your password' : null,
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: Text('Forgot Password?', style: TextStyle(color: fueRed)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: fueRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('LOGIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: Text('Register Now', style: TextStyle(color: fueRed, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}