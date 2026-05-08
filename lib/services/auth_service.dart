import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // get current user logged in 
  User? get currentUser => _auth.currentUser;

  // track login aw logout changes  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

// register user with email & password  
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role, 
  }) async {
    try {
    // clean input 3shan mayezharsh errors fel login      
      final String cleanEmail = email.trim().toLowerCase();
      final String cleanPassword = password.trim();

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );

      // check if first half of mail is 8 digits user is student, otherwise admin
      String idPart = cleanEmail.split('@')[0];
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

// login with email & password  
  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // remove spaces w uppercase
      return await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // get user role mn firestore
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

  // logout user  
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // send reset password email
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // handle firebase auth errors
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