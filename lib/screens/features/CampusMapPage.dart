import 'package:flutter/material.dart';

class CampusMapPage extends StatelessWidget {
  const CampusMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: const Color(0xffb1170c),
        foregroundColor: Colors.white,
        centerTitle: true,

        title: const Text(
          "FUE Campus Map",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          // INSTRUCTIONS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

            color: Colors.white,

            child: const Row(
              children: [
                Icon(Icons.touch_app, color: Color(0xffb1170c)),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "Tap any building on the map to view its information.",

                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // MAP
          Expanded(
            child: InteractiveViewer(
              minScale: 0.7,
              maxScale: 4,
              panEnabled: true,

              child: AspectRatio(
                aspectRatio: 1109 / 794,

                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final mapWidth = constraints.maxWidth;

                    final mapHeight = constraints.maxHeight;

                    return Stack(
                      children: [
                        // MAP IMAGE
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/map.png',
                            fit: BoxFit.contain,

                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    Icon(
                                      Icons.map_outlined,
                                      size: 100,
                                      color: Colors.grey,
                                    ),

                                    SizedBox(height: 10),

                                    Text(
                                      "Map image not found",

                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // A
                        _responsiveBuilding(
                          context,

                          x: 0.78,
                          y: 0.11,
                          w: 0.15,
                          h: 0.18,

                          mapWidth: mapWidth,
                          mapHeight: mapHeight,

                          buildingName: "Building A",

                          faculty: "Faculty of Engineering & Technology",

                          details:
                              "Contains engineering lecture halls, labs, workshops, and faculty offices.",
                        ),

                        // B
                        _responsiveBuilding(
                          context,

                          x: 0.69,
                          y: 0.40,
                          w: 0.20,
                          h: 0.22,

                          mapWidth: mapWidth,
                          mapHeight: mapHeight,

                          buildingName: "Building B",

                          faculty:
                              "Faculty of Computers & Information Technology",

                          details:
                              "Contains computer labs, programming classrooms, and IT facilities.",
                        ),

                        // C
                        _responsiveBuilding(
                          context,

                          x: 0.66,
                          y: 0.18,
                          w: 0.13,
                          h: 0.16,

                          mapWidth: mapWidth,
                          mapHeight: mapHeight,

                          buildingName: "Building C",

                          faculty:
                              "Faculty of Commerce & Business Administration",

                          details:
                              "Contains business lecture halls, classrooms, and administration offices.",
                        ),

                        // D
                        _responsiveBuilding(
                          context,

                          x: 0.50,
                          y: 0.15,
                          w: 0.16,
                          h: 0.33,

                          mapWidth: mapWidth,
                          mapHeight: mapHeight,

                          buildingName: "Building D",

                          faculty: "Faculty of Pharmacy",

                          details:
                              "Contains pharmaceutical labs, lecture halls, and faculty administration.",
                        ),

                        // E
                        _responsiveBuilding(
                          context,

                          x: 0.55,
                          y: 0.63,
                          w: 0.15,
                          h: 0.11,

                          mapWidth: mapWidth,
                          mapHeight: mapHeight,

                          buildingName: "Building E",

                          faculty: "Faculty of Economics & Political Science",

                          details:
                              "Contains economics and political science lecture halls and classrooms.",
                        ),

                        // F
                        _responsiveBuilding(
                          context,

                          x: 0.06,
                          y: 0.10,
                          w: 0.23,
                          h: 0.22,

                          mapWidth: mapWidth,
                          mapHeight: mapHeight,

                          buildingName: "Building F",

                          faculty: "Dental Hospital",

                          details:
                              "Contains dental clinics, treatment rooms, and medical facilities.",
                        ),

                        // G
                        _responsiveBuilding(
                          context,

                          x: 0.08,
                          y: 0.41,
                          w: 0.12,
                          h: 0.10,

                          mapWidth: mapWidth,
                          mapHeight: mapHeight,

                          buildingName: "Building G",

                          faculty:
                              "Pharmaceutical Research & Development Center",

                          details:
                              "Research center dedicated to pharmaceutical development and innovation.",
                        ),

                        // H
                        _responsiveBuilding(
                          context,

                          x: 0.11,
                          y: 0.56,
                          w: 0.16,
                          h: 0.16,

                          mapWidth: mapWidth,
                          mapHeight: mapHeight,

                          buildingName: "Building H",

                          faculty: "Faculty of Oral & Dental Medicine",

                          details:
                              "Contains dental lecture halls, simulation labs, and academic offices.",
                        ),

                        // I
                        _responsiveBuilding(
                          context,

                          x: 0.35,
                          y: 0.15,
                          w: 0.14,
                          h: 0.18,

                          mapWidth: mapWidth,
                          mapHeight: mapHeight,

                          buildingName: "Building I",

                          faculty: "Food Court",

                          details:
                              "Contains restaurants, cafes, seating areas, and food services.",
                        ),

                        // J
                        _responsiveBuilding(
                          context,

                          x: 0.72,
                          y: 0.46,
                          w: 0.20,
                          h: 0.22,

                          mapWidth: mapWidth,
                          mapHeight: mapHeight,

                          buildingName: "Building J",

                          faculty: "Main Auditorium",

                          details:
                              "Used for events, seminars, conferences, and university activities.",
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _responsiveBuilding(
    BuildContext context, {

    required double x,
    required double y,
    required double w,
    required double h,

    required double mapWidth,
    required double mapHeight,

    required String buildingName,
    required String faculty,
    required String details,
  }) {
    return Positioned(
      left: mapWidth * x,
      top: mapHeight * y,

      child: GestureDetector(
        onTap: () {
          _showBuildingInfo(context, buildingName, faculty, details);
        },

        child: Container(
          width: mapWidth * w,
          height: mapHeight * h,
          color: Colors.transparent,
        ),
      ),
    );
  }

  static void _showBuildingInfo(
    BuildContext context,
    String buildingName,
    String faculty,
    String details,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                buildingName,

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffb1170c),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                faculty,

                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                details,

                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),

              const SizedBox(height: 20),

              const Row(
                children: [
                  Icon(Icons.location_on, color: Color(0xffb1170c)),

                  SizedBox(width: 8),

                  Text("FUE Campus", style: TextStyle(fontSize: 15)),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
