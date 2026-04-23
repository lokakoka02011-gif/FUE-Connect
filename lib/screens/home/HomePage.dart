import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. Declare the controller here
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    // 2. ALWAYS dispose your controllers to avoid memory leaks
    _pageController.dispose();
    super.dispose();
  }

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
      "type": "internship",
      "title": "Software Internship",
      "subtitle": "IT Department",
      "image": "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?q=80&w=400",
      "route": "/internships",
    },
    {
      "type": "club",
      "title": "Robotics Club",
      "subtitle": "Engineering",
      "image": "https://images.unsplash.com/photo-1535378917042-10a22c95931a?q=80&w=400",
      "route": "/clubs",
    },
  ];

  final List<String> slideshowImages = const [
    "assets/images/slideshow.png",
    "assets/images/slideshow (2).png",
    "assets/images/slideshow (3).png",
    "assets/images/slideshow (4).png",
    "assets/images/slideshow (5).png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pro-tip: Add an AppBar or a SafeArea if you aren't using one in a parent widget
      body: SafeArea( 
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ SLIDESHOW
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: slideshowImages.length,
                  controller: _pageController, // Use the managed controller
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Placeholder color
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

              const SizedBox(height: 10),

              // CATEGORIES
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: const [
                    CategoryItem(icon: Icons.group, label: "Clubs", routeName: "/clubs"),
                    CategoryItem(icon: Icons.event, label: "Events", routeName: "/events"),
                    CategoryItem(icon: Icons.volunteer_activism, label: "Volunteer", routeName: "/volunteer"),
                    CategoryItem(icon: Icons.work_outline, label: "Internships", routeName: "/internships"),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Text(
                  "Recommended for you",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // 🔥 RECOMMENDED CARDS
              SizedBox(
                height: 240, // Increased slightly to prevent text clipping
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 12),
                  itemCount: recommendedItems.length,
                  itemBuilder: (context, index) {
                    final item = recommendedItems[index];

                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(context, item["route"]),
                      child: Container(
                        width: 180,
                        margin: const EdgeInsets.only(left: 12, bottom: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                child: Image.network(
                                  item["image"],
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  // Added error builder to prevent crashes if URL is dead
                                  errorBuilder: (context, error, stackTrace) => 
                                    Container(height: 120, color: Colors.grey, child: const Icon(Icons.broken_image)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffb1170c),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        item["type"].toString().toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item["title"],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      item["subtitle"],
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
      borderRadius: BorderRadius.circular(12),
      child: SizedBox( // Changed Container to SizedBox for better performance
        width: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: Theme.of(context).primaryColor),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}