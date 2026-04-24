import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. ADDED: Initializing GoogleSignIn with your specific Client ID for Web support
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '775315883248-frvh6gsggad5l5dlkl8p05fl75vkf96c.apps.googleusercontent.com',
  );

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
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
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
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ── GOOGLE SIGN-IN ───────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 2. UPDATED: Using the initialized _googleSignIn instance
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; 

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final doc =
          await _db.collection('users').doc(userCredential.user!.uid).get();

      if (!doc.exists) {
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'firstName': userCredential.user!.displayName?.split(' ').first ?? '',
          'lastName': userCredential.user!.displayName?.split(' ').last ?? '',
          'email': userCredential.user!.email,
          'profilePicUrl': userCredential.user!.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // ── SIGN OUT ─────────────────────────────────────────
  Future<void> signOut() async {
    // 3. UPDATED: Using the same instance for sign out
    await _googleSignIn.signOut(); 
    await _auth.signOut();
  }

  // ── PASSWORD RESET ───────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── ERROR HANDLER ────────────────────────────────────
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}