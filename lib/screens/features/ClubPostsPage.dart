import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';

class ClubPostsPage extends StatelessWidget {
  final String clubId;
  final String clubName;

  const ClubPostsPage({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  Widget build(BuildContext context) {
    const Color fueRed = Color(0xffb1170c);

    return Scaffold(
      appBar: AppBar(
        title: Text("$clubName Posts"),
        backgroundColor: fueRed,
        foregroundColor: Colors.white,
      ),
    // load club posts from Firestore in real-time 

    body: FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),

      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingIndicator());
        }

        final userData =
            userSnapshot.data?.data() as Map<String, dynamic>?;

        final joinedClubs =
            List<String>.from(userData?['joinedClubs'] ?? []);

        final isMember = joinedClubs.contains(clubId);

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Clubs')
              .doc(clubId)
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .snapshots(),

          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error loading posts"),
              );
            }

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: LoadingIndicator(),
              );
            }

            final posts = snapshot.data!.docs;

            if (posts.isEmpty) {
              return const Center(
                child: Text(
                  "No posts yet",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final data =
                    posts[index].data() as Map<String, dynamic>;

                final bool isExclusive =
                    data['isExclusive'] ?? false;

                final bool isLocked =
                    isExclusive && !isMember;

                return Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                data['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            if (isExclusive)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: fueRed,
                                  borderRadius:
                                      BorderRadius.circular(20),
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

                        if (isLocked)
                          const Text(
                            "Join this club to view this post.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          Text(data['content'] ?? ''),
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