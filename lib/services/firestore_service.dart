import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser!.uid;

  // ── READ: Get current user's profile ─────────────────
  Future<Map<String, dynamic>?> getUserProfile() async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  // ── READ: Stream of user profile (real-time) ─────────
  Stream<DocumentSnapshot> getUserProfileStream() {
    return _db.collection('users').doc(userId).snapshots();
  }

  // ── UPDATE: Update user profile ───────────────────────
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  // ── CREATE: Add a new post ────────────────────────────
  Future<DocumentReference> createPost({
    required String title,
    required String content,
  }) async {
    return await _db.collection('posts').add({
      'title': title,
      'content': content,
      'authorId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': 0,
    });
  }

  // ── READ: Get all posts (real-time stream) ────────────
  Stream<QuerySnapshot> getPostsStream() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ── UPDATE: Like a post ───────────────────────────────
  Future<void> likePost(String postId) async {
    await _db.collection('posts').doc(postId).update({
      'likes': FieldValue.increment(1),
    });
  }

  // ── DELETE: Delete a post ─────────────────────────────
  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }
}