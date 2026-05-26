import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CURRENT USER
  User? get currentUser => _auth.currentUser;

  // AUTH STATE CHANGES
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // REGISTER
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    try {
      final String cleanEmail = email.trim().toLowerCase();
      final String cleanPassword = password.trim();

      // CREATE AUTH ACCOUNT
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: cleanEmail,
            password: cleanPassword,
          );

      // SAVE USER TO FIRESTORE
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,

        'firstName': firstName.trim(),
        'lastName': lastName.trim(),

        'email': cleanEmail,

        // IMPORTANT
        'role': role,

        'createdAt': FieldValue.serverTimestamp(),

        // OPTIONAL DEFAULT FIELDS
        'profilePicUrl': '',
        'phone': '',
        'faculty': '',
        'year': '',
        'gpa': '',
        'bio': '',
        'skills': [],
        'interests': [],
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // LOGIN
  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final String cleanEmail = email.trim().toLowerCase();
      final String cleanPassword = password.trim();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // GET USER ROLE
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;

        return data['role'] ?? 'student';
      }

      return 'student';
    } catch (e) {
      print("ROLE ERROR: $e");

      return 'student';
    }
  }

  // GET FULL USER DATA
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      print("GET USER DATA ERROR: $e");

      return null;
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // RESET PASSWORD
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ERROR HANDLER
  String _handleAuthError(FirebaseAuthException e) {
    print("Firebase Auth Error Code: ${e.code}");

    switch (e.code) {
      case 'weak-password':
        return 'Password must be at least 6 characters.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-not-found':
        return 'No user found with this email.';

      case 'wrong-password':
        return 'Incorrect password.';

      case 'invalid-credential':
        return 'Wrong email or password.';

      case 'too-many-requests':
        return 'Too many attempts. Try again later.';

      case 'network-request-failed':
        return 'Check your internet connection.';

      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}
