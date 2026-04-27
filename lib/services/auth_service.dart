import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── REGISTER WITH EMAIL & PASSWORD ──────────────────
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role, // Kept to avoid UI errors, but overwritten by logic below
  }) async {
    try {
      // Clean inputs to prevent "Wrong Password" or "User Not Found" errors
      final String cleanEmail = email.trim().toLowerCase();
      final String cleanPassword = password.trim();

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );

      // --- LOGIC: 8 digits = student, otherwise = admin ---
      String idPart = cleanEmail.split('@')[0];
      // Regex checks if the ID part is EXACTLY 8 digits
      bool is8Digits = RegExp(r'^\d{8}$').hasMatch(idPart);
      String assignedRole = is8Digits ? 'student' : 'admin';

      await _db.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': cleanEmail,
        'role': assignedRole, 
        'uid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'profilePicUrl': '',
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ── LOGIN WITH EMAIL & PASSWORD ──────────────────────
  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Clean inputs to avoid accidental space/case errors
      return await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ── GET USER ROLE ────────────────────────────────────
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return (doc.data() as Map<String, dynamic>)['role'] ?? 'student';
      }
      return 'student';
    } catch (e) {
      return 'student';
    }
  }

  // ── SIGN OUT ─────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── PASSWORD RESET ───────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ── ERROR HANDLER ────────────────────────────────────
  String _handleAuthError(FirebaseAuthException e) {
    // Printing the code helps you debug in the VS Code console
    print("Firebase Auth Error Code: ${e.code}");
    
    switch (e.code) {
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No user found with this ID.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential': 
        return 'Wrong password or ID. Please check your credentials.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}