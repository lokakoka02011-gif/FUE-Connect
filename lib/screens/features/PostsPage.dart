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

    final user = FirebaseAuth.instance.currentUser;

    // USER NOT LOGGED IN
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(clubName != null ? "$clubName Posts" : "Posts"),
        backgroundColor: fueRed,
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(),

        builder: (context, userSnapshot) {
          // LOADING
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }

          // USER DATA
          final userData =
              userSnapshot.data?.data() as Map<String, dynamic>? ?? {};

          // JOINED CLUBS
          final joinedClubs =
              (userData['joinedClubs'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('posts').snapshots(),

            builder: (context, snapshot) {
              // ERROR
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              // LOADING
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingIndicator());
              }

              // POSTS
              final allPosts = snapshot.data?.docs ?? [];

              // FILTER POSTS
              final visiblePosts = allPosts.where((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final visibility = (data['visibility'] ?? 'public').toString();

                final postClubName = (data['clubName'] ?? '').toString();

                // FILTER CLUB PAGE
                if (clubName != null && postClubName != clubName) {
                  return false;
                }

                // PUBLIC POSTS
                if (visibility == 'public') {
                  return true;
                }

                // CLUB EXCLUSIVE
                if (visibility == 'clubExclusive') {
                  return joinedClubs.contains(postClubName);
                }

                return false;
              }).toList();

              // NO POSTS
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

              // POSTS LIST
              return ListView.builder(
                itemCount: visiblePosts.length,

                itemBuilder: (context, index) {
                  final data =
                      visiblePosts[index].data() as Map<String, dynamic>;

                  final visibility = (data['visibility'] ?? 'public')
                      .toString();

                  final isExclusive = visibility == 'clubExclusive';

                  final title = (data['title'] ?? 'No Title').toString();

                  final content = (data['content'] ?? '').toString();

                  final type = (data['type'] ?? '').toString();

                  final club = (data['clubName'] ?? '').toString();

                  final imageUrl = (data['imgUrl'] ?? '').toString();

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
                                  title,
                                  style: const TextStyle(
                                    fontSize: 18,
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

                          const SizedBox(height: 8),

                          // TYPE
                          if (type.isNotEmpty)
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
                                type.toUpperCase(),

                                style: TextStyle(
                                  color: fueRed,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),

                          const SizedBox(height: 8),

                          // CLUB NAME
                          if (club.isNotEmpty)
                            Text(
                              club,

                              style: TextStyle(
                                color: fueRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                          const SizedBox(height: 8),

                          // IMAGE
                          if (imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),

                              child: Image.network(
                                imageUrl,

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
                          Text(content, style: const TextStyle(fontSize: 15)),
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
