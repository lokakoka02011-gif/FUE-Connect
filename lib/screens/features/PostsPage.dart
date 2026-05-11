import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';

class PostsPage extends StatelessWidget {
  final String? clubName;

  const PostsPage({super.key, this.clubName});

  @override
  Widget build(BuildContext context) {
    const Color fueRed = Color(0xffb1170c);

    return Scaffold(
      appBar: AppBar(
        title: Text(clubName != null ? "$clubName Posts" : "Posts"),

        backgroundColor: fueRed,
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),

        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }

          final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

          final joinedClubs = List<String>.from(userData?['joinedClubs'] ?? []);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('featured', descending: true)
                .orderBy('createdAt', descending: true)
                .snapshots(),

            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading posts"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingIndicator());
              }

              final allPosts = snapshot.data!.docs;

              final visiblePosts = allPosts.where((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final visibility = data['visibility'] ?? 'public';

                final postClubName = data['clubName'];

                // FILTER CLUB POSTS
                if (clubName != null && postClubName != clubName) {
                  return false;
                }

                // PUBLIC POSTS
                if (visibility == 'public') {
                  return true;
                }

                // CLUB EXCLUSIVE POSTS
                if (visibility == 'clubExclusive') {
                  return joinedClubs.contains(postClubName);
                }

                return false;
              }).toList();

              if (visiblePosts.isEmpty) {
                return Center(
                  child: Text(
                    clubName != null
                        ? "No posts available for $clubName"
                        : "No posts available",

                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                itemCount: visiblePosts.length,

                itemBuilder: (context, index) {
                  final data =
                      visiblePosts[index].data() as Map<String, dynamic>;

                  final visibility = data['visibility'] ?? 'public';

                  final bool isExclusive = visibility == 'clubExclusive';

                  final bool isFeatured = data['featured'] ?? false;

                  return Card(
                    margin: const EdgeInsets.all(12),

                    elevation: 3,

                    child: Padding(
                      padding: const EdgeInsets.all(12),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // HEADER
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['title'] ?? 'No Title',

                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // FEATURED
                              if (isFeatured)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),

                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.amber,

                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: const Text(
                                    "Featured",

                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                              // MEMBERS ONLY
                              if (isExclusive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),

                                  decoration: BoxDecoration(
                                    color: fueRed,

                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: const Text(
                                    "Members Only",

                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // TYPE
                          if (data['type'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,

                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: Text(
                                data['type'].toString().toUpperCase(),

                                style: TextStyle(
                                  color: fueRed,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),

                          const SizedBox(height: 8),

                          // CLUB NAME
                          if (data['clubName'] != null)
                            Text(
                              data['clubName'],

                              style: TextStyle(
                                color: fueRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                          const SizedBox(height: 8),

                          // IMAGE
                          if ((data['imgUrl'] ?? '').toString().isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),

                              child: Image.network(
                                data['imgUrl'],

                                fit: BoxFit.cover,

                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 180,

                                    width: double.infinity,

                                    color: Colors.grey[300],

                                    child: const Icon(
                                      Icons.image_not_supported,

                                      size: 40,

                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 10),

                          // CONTENT
                          Text(
                            data['content'] ?? '',

                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
