import 'dart:async'; // Required for the automatic timer
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  // 1. SLIDESHOW IMAGES
  final List<String> slideshowImages = const [
    "assets/images/slideshow.png",
    "assets/images/slideshow (2).png",
    "assets/images/slideshow (3).png",
    "assets/images/slideshow (4).png",
    "assets/images/slideshow (5).png",
  ];

  // 2. RECOMMENDED ITEMS DATA
  final List<Map<String, dynamic>> recommendedItems = const [
    {
      "type": "volunteer",
      "title": "Campus Green Initiative",
      "subtitle": "FUE Sustainability Club",
      "image": "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?q=80&w=400",
      "route": "/volunteer",
    },
    {
      "type": "event",
      "title": "Spring Career Fair",
      "subtitle": "Main Hall",
      "image": "https://images.unsplash.com/photo-1511578314322-379afb476865?q=80&w=400",
      "route": "/events",
    },
    {
      "type": "opportunity",
      "title": "Software Internship",
      "subtitle": "IT Department",
      "image": "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?q=80&w=400",
      "route": "/opportunities",
    },
    {
      "type": "club",
      "title": "Robotics Club",
      "subtitle": "Engineering",
      "image": "https://images.unsplash.com/photo-1535378917042-10a22c95931a?q=80&w=400",
      "route": "/clubs",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9, initialPage: 0);

    // --- SETUP AUTOMATIC TIMER ---
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < slideshowImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Stop timer to prevent memory leaks
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
              // --- SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Search for clubs, events...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ),

              // --- AUTOMATIC SLIDESHOW ---
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: slideshowImages.length,
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: AssetImage(slideshowImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              // --- CATEGORIES SECTION ---
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
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: const [
                    CategoryItem(
                        icon: Icons.group_rounded,
                        label: "Clubs",
                        routeName: "/clubs"),
                    CategoryItem(
                        icon: Icons.event_available_rounded,
                        label: "Events",
                        routeName: "/events"),
                    CategoryItem(
                        icon: Icons.volunteer_activism_rounded,
                        label: "Volunteer",
                        routeName: "/volunteer"),
                    CategoryItem(
                        icon: Icons.work_rounded,
                        label: "Opportunities",
                        routeName: "/opportunities"),
                  ],
                ),
              ),

              // --- RECOMMENDED SECTION ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Text(
                  "Recommended for you",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 12),
                  itemCount: recommendedItems.length,
                  itemBuilder: (context, index) {
                    final item = recommendedItems[index];

                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(context, item["route"]),
                      child: Container(
                        width: 200,
                        margin: const EdgeInsets.only(left: 12, bottom: 10),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15)),
                                child: Image.network(
                                  item["image"],
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffb1170c)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item["type"].toString().toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xffb1170c),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item["title"],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item["subtitle"],
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET CLASSES DEFINED OUTSIDE OF HOMEPAGE STATE ---

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