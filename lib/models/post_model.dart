class PostModel {
  final String postId;
  final String title;
  final String description;
  final String uid; 
  final DateTime createdAt;
  final List<String> likes;

  PostModel({
    required this.postId,
    required this.title,
    required this.description,
    required this.uid,
    required this.createdAt,
    required this.likes,
  });

// converts map (firestore data) l PostModel w handles missing values law fe fields na2sa
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      uid: map['uid'] ?? '',
      createdAt: (map['createdAt'] != null) 
          ? map['createdAt'].toDate() 
          : DateTime.now(),
      likes: List<String>.from(map['likes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'title': title,
      'description': description,
      'uid': uid,
      'createdAt': createdAt,
      'likes': likes,
    };
  }
}