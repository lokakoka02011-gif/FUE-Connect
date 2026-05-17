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
                            fit: BoxFit.fill,

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
  y: 0.20,
  w: 0.13,
  h: 0.10,

  mapWidth: mapWidth,
  mapHeight: mapHeight,

  buildingName: "Building A",

  faculty: "Faculty of Engineering & Technology",

  details:
      "Contains engineering lecture halls, labs, workshops, and faculty offices.",
),

// A Lower
_responsiveBuilding(
  context,

  x: 0.84,
  y: 0.30,
  w: 0.07,
  h: 0.14,

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

  x: 0.81,
  y: 0.43,
  w: 0.07,
  h: 0.20,
  rotation: -0.72,
  


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

  x: 0.68,
  y: 0.20,

  w: 0.07,
  h: 0.21,

  mapWidth: mapWidth,
  mapHeight: mapHeight,

  buildingName: "Building C",

  faculty:
      "Faculty of Commerce & Business Administration",

  details:
      "Contains business lecture halls, classrooms, and administration offices.",
),

// D TOP
_responsiveBuilding(
  context,

  x: 0.54,
  y: 0.20,
  w: 0.06,
  h: 0.25,

  mapWidth: mapWidth,
  mapHeight: mapHeight,

  buildingName: "Building D",

  faculty: "Faculty of Pharmacy",

  details:
      "Contains pharmaceutical labs, lecture halls, and faculty administration.",
),

// D LOWER
_responsiveBuilding(
  context,

  x: 0.59,
  y: 0.4,
  w: 0.09,
  h: 0.16,
  rotation: -0.78,


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
  y: 0.62,
  w: 0.11,
  h: 0.09,

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

  x: 0.10,
  y: 0.20,
  w: 0.17,
  h: 0.18,

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

  x: 0.10,
  y: 0.39,
  w: 0.10,
  h: 0.18,

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

  x: 0.14,
  y: 0.57,
  w: 0.08,
  h: 0.14,
  rotation: -0.28,


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

  x: 0.37,
  y: 0.21,
  w: 0.11,
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

  x: 0.73,
  y: 0.53,
  w: 0.1,
  h: 0.20,
  rotation: -0.72,
  


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
    double rotation = 0,
  }) {
    return Positioned(
      left: mapWidth * x,
      top: mapHeight * y,

      child: GestureDetector(
        onTap: () {
          _showBuildingInfo(context, buildingName, faculty, details);
        },

        child: Transform.rotate(
          angle: rotation,

          child: Container(
            width: mapWidth * w,
            height: mapHeight * h,

            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
          ),
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
