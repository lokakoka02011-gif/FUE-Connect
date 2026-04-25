import 'package:flutter/material.dart';

class AcademicCalendarPage extends StatelessWidget {
  const AcademicCalendarPage({super.key});

  final List<Map<String, String>> dates = const [
    {"event": "Fall Semester Starts", "date": "Sept 20, 2026"},
    {"event": "Midterm Exams", "date": "Nov 15, 2026"},
    {"event": "Spring Registration", "date": "Jan 10, 2027"},
    {"event": "Final Graduation Projects", "date": "May 20, 2027"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Academic Calendar")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0), // Correct syntax
        itemCount: dates.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0), // Correct syntax
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Color(0xffb1170c)),
              title: Text(dates[index]["event"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(dates[index]["date"]!),
            ),
          );
        },
      ),
    );
  }
}