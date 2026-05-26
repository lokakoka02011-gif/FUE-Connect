import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  late Timer _timer;
  late Stream<QuerySnapshot> _postsStream;

  int _currentPage = 0;

  int notificationCount = 0;
  final Set<String> _savedPostIds = {};

  final List<String> slideshowImages = const [
    "assets/images/slideshow.png",
    "assets/images/slideshow (2).png",
    "assets/images/slideshow (3).png",
    "assets/images/slideshow (4).png",
    "assets/images/slideshow (5).png",
  ];

  @override
  void initState() {
    super.initState();

    _postsStream = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();

    _pageController = PageController();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;

        if (_currentPage >= slideshowImages.length) {
          _currentPage = 0;
        }

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // SLIDESHOW
              SizedBox(
                height: 200,

                child: Stack(
                  alignment: Alignment.center,

                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: slideshowImages.length,

                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },

                      itemBuilder: (context, index) {
                        return Image.asset(
                          slideshowImages[index],

                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),

                    Positioned(
                      left: 10,

                      child: _buildNavArrow(Icons.chevron_left, () {
                        if (_currentPage > 0) {
                          _currentPage--;

                          _pageController.animateToPage(
                            _currentPage,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      }),
                    ),

                    Positioned(
                      right: 10,

                      child: _buildNavArrow(Icons.chevron_right, () {
                        if (_currentPage < slideshowImages.length - 1) {
                          _currentPage++;

                          _pageController.animateToPage(
                            _currentPage,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CATEGORIES
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),

                child: Text(
                  "Categories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 100,
                width: double.infinity,

                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: const [
                      Expanded(
                        child: CategoryItem(
                          icon: Icons.group_rounded,
                          label: "Clubs",
                          routeName: "/clubs",
                        ),
                      ),

                      Expanded(
                        child: CategoryItem(
                          icon: Icons.event_available_rounded,
                          label: "Events",
                          routeName: "/events",
                        ),
                      ),

                      Expanded(
                        child: CategoryItem(
                          icon: Icons.volunteer_activism_rounded,
                          label: "Volunteer",
                          routeName: "/volunteer",
                        ),
                      ),

                     Expanded(
                      child: CategoryItem(
                        icon: Icons.school_rounded,
                        label: "Internships",
                        routeName: "/internships",
                      ),
                    ),

                    Expanded(
                      child: CategoryItem(
                        icon: Icons.work_rounded,
                        label: "Jobs",
                        routeName: "/jobs",
                      ),
                    ),
                    ],
                  ),
                ),
              ),

              const Divider(thickness: 1, height: 30),

              // POSTS TITLE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),

                child: Text(
                  "Latest Posts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              // POSTS
              StreamBuilder<QuerySnapshot>(
                stream: _postsStream,

                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading posts"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LoadingIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("No posts yet."),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,

                    itemBuilder: (context, index) {
                      final doc = docs[index];

                      final data = doc.data() as Map<String, dynamic>;

                      final clubId = data["clubName"] ?? "FUE Connect";

                      return _buildPostCard(
                        data,
                        clubId,
                        doc.id,
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, String clubId, String postId,) {
    String timeDisplay = "Recently";

    if (post["createdAt"] != null) {
      DateTime dt = (post["createdAt"] as Timestamp).toDate();

      timeDisplay = "${dt.day}/${dt.month} ${dt.hour}:${dt.minute}";
    }

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xffb1170c).withOpacity(0.1),

                child: const Icon(
                  Icons.group,
                  color: Color(0xffb1170c),
                  size: 20,
                ),
              ),

              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    clubId,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  Text(
                    post["title"] ?? "Post",

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              subtitle: Text(timeDisplay, style: const TextStyle(fontSize: 12)),
              trailing: IconButton(
                icon: Icon(
                  _savedPostIds.contains(postId)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: _savedPostIds.contains(postId)
                      ? const Color(0xffb1170c)
                      : Colors.grey,
                ),

                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;

                  if (uid == null) return;

                  final savedRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('saved_items')
                      .doc(postId);

                  final doc = await savedRef.get();

                  if (doc.exists) {
                    await savedRef.delete();

                    setState(() {
                      _savedPostIds.remove(postId);
                    });
                  } else {
                    await savedRef.set({
                      'title': post['title'],
                      'type': 'Post',
                      'route': '/home',
                      'savedAt': Timestamp.now(),
                    });

                    setState(() {
                      _savedPostIds.add(postId);
                    });
                  }
                },
              ),
          ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4,
              ),

              child: Text(
                post["content"] ?? "",

                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),

            const SizedBox(height: 10),

            if (post["imgUrl"] != null &&
                post["imgUrl"].toString().isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),

                child: Image.network(
                  post["imgUrl"],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print(error);

                      return Container(
                        height: 200,
                        color: Colors.grey,
                        child: Center(
                          child: Text(error.toString()),
                        ),
                      );
                    },
                ),
              ),
          ],
        ),
    );
  }

  Widget _buildNavArrow(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(4),

        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),

        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String routeName;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.label,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, routeName),

      borderRadius: BorderRadius.circular(15),

      child: Container(
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 4),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: const Color(0xffb1170c).withOpacity(0.05),

                shape: BoxShape.circle,
              ),

              child: Icon(icon, size: 28, color: const Color(0xffb1170c)),
            ),

            const SizedBox(height: 8),

            Text(
              label,

              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),

              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
