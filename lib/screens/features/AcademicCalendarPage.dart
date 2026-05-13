import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

import 'EventsPage.dart';

class AcademicCalendarPage extends StatefulWidget {
  const AcademicCalendarPage({super.key});

  @override
  State<AcademicCalendarPage> createState() => _AcademicCalendarPageState();
}

class _AcademicCalendarPageState extends State<AcademicCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Map<String, dynamic>>> events = {};

  @override
  void initState() {
    super.initState();

    _selectedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );

    loadEvents();
  }

  Future<void> loadEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Events')
        .get();

    Map<DateTime, List<Map<String, dynamic>>> loadedEvents = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();

      if (data['date'] == null) continue;

      Timestamp timestamp = data['date'];

      DateTime date = timestamp.toDate();

      DateTime normalizedDate = DateTime(date.year, date.month, date.day);

      if (loadedEvents[normalizedDate] == null) {
        loadedEvents[normalizedDate] = [];
      }

      loadedEvents[normalizedDate]!.add({
        'id': doc.id,
        'name': data['name'] ?? 'Event',
        'description': data['description'] ?? '',
      });
    }

    setState(() {
      events = loadedEvents;
    });
  }

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = getEventsForDay(_selectedDay!);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(title: const Text("Academic Calendar"), centerTitle: true),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,

              // REMOVE 2 WEEKS BUTTON
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),

              // MAKE CALENDAR FULL MONTH ONLY
              availableGestures: AvailableGestures.all,

              calendarFormat: CalendarFormat.month,

              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },

              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = DateTime(
                    selectedDay.year,
                    selectedDay.month,
                    selectedDay.day,
                  );

                  _focusedDay = focusedDay;
                });
              },

              eventLoader: getEventsForDay,

              calendarStyle: CalendarStyle(
                // REMOVE UGLY ORANGE
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),

                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),

                markerDecoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),

                markersMaxCount: 3,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: selectedEvents.isEmpty
                ? const Center(child: Text("No events for this day"))
                : ListView.builder(
                    itemCount: selectedEvents.length,

                    itemBuilder: (context, index) {
                      final event = selectedEvents[index];

                      return Card(
                        elevation: 2,

                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        child: ListTile(
                          leading: const Icon(Icons.event, color: Colors.red),

                          title: Text(event['name']),

                          subtitle: Text(
                            event['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          onTap: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) => const EventsPage(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
