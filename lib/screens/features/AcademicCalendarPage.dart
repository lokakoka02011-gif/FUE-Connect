import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AcademicCalendarPage extends StatefulWidget {
  const AcademicCalendarPage({super.key});

  @override
  State<AcademicCalendarPage> createState() => _AcademicCalendarPageState();
}
  class _AcademicCalendarPageState extends State<AcademicCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Academic Calendar")),
      // calendar view lel events 
      body: Column(
        children: [
        
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,

          selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },       
          ),
          const SizedBox(height: 10),
              Text(
                _selectedDay == null
                    ? "Select a day"
                    : "Selected: ${_selectedDay!.toLocal()}",     
              ),           
            ]
          ),
        );
  }
}