import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

// get current user id
  String get userId => _auth.currentUser!.uid;

  // get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  // stream user profile (real-time)
  Stream<DocumentSnapshot> getUserProfileStream() {
    return _db.collection('users').doc(userId).snapshots();
  }

  // update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  // create new post
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

  // get posts stream
  Stream<QuerySnapshot> getPostsStream() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // like a post 
  Future<void> likePost(String postId) async {
    await _db.collection('posts').doc(postId).update({
      'likes': FieldValue.increment(1),
    });
  }

  // Delete post 
  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }
}