import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  Map<DateTime, List<Map<String, dynamic>>> usedMedicinesMap = {};
  Map<DateTime, String> medicineStatusMap = {}; // Günlerin durumunu tutan harita
  int totalMedicinesCount = 0; // Kullanılması gereken toplam ilaç sayısı
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _firstDay = DateTime.utc(2000, 1, 1);
  DateTime _lastDay = DateTime.utc(2100, 12, 31);
  List<Map<String, dynamic>> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    fetchUsedMedicines();
    fetchMedicineStatus();
  }

  void fetchUsedMedicines() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DatabaseReference usedMedicinesRef = _databaseReference
          .child('users')
          .child(currentUser.uid)
          .child('todayOfUsedMedicine');

      try {
        DatabaseEvent event = await usedMedicinesRef.once();
        DataSnapshot snapshot = event.snapshot;
        Map<dynamic, dynamic>? usedMedicinesData = snapshot.value as Map<dynamic, dynamic>?;

        if (usedMedicinesData != null) {
          Map<DateTime, List<Map<String, dynamic>>> tempMedicinesMap = {};

          usedMedicinesData.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              value.forEach((medicineName, details) {
                if (details is Map<dynamic, dynamic> && details.containsKey('time')) {
                  List<String> dateParts = key.split('-');
                  if (dateParts.length == 3) {
                    String year = dateParts[0];
                    String month = dateParts[1].padLeft(2, '0');
                    String day = dateParts[2].padLeft(2, '0');
                    String dateString = '$year-$month-$day';
                    try {
                      DateTime date = DateTime.parse(dateString);
                      if (!tempMedicinesMap.containsKey(date)) {
                        tempMedicinesMap[date] = [];
                      }
                      tempMedicinesMap[date]!.add({
                        'name': medicineName,
                        'time': details['time'],
                      });
                    } catch (e) {
                      print('Invalid date format for dateString: $dateString');
                    }
                  }
                }
              });
            }
          });

          setState(() {
            usedMedicinesMap = tempMedicinesMap;
            totalMedicinesCount = usedMedicinesData.length;
            // İlk ve son tarihleri belirle
            if (tempMedicinesMap.isNotEmpty) {
              List<DateTime> dates = tempMedicinesMap.keys.toList();
              dates.sort();
              _firstDay = dates.first;
              _lastDay = dates.last;
            }
          });
        }
      } catch (error) {
        print('Error fetching used medicines: $error');
      }
    }
  }

  void fetchMedicineStatus() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DatabaseReference medicinesRef = _databaseReference
          .child('users')
          .child(currentUser.uid)
          .child('medicines');

      try {
        DatabaseEvent event = await medicinesRef.once();
        DataSnapshot snapshot = event.snapshot;
        Map<dynamic, dynamic>? medicinesData = snapshot.value as Map<dynamic, dynamic>?;

        if (medicinesData != null) {
          Map<DateTime, String> tempStatusMap = {};

          DateTime now = DateTime.now();
          String todayString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

          medicinesData.forEach((medicineName, medicineDetails) {
            if (medicineDetails is Map && medicineDetails['days'] is Map) {
              Map<dynamic, dynamic> daysData = medicineDetails['days'] as Map<dynamic, dynamic>;

              daysData.forEach((day, dates) {
                try {
                  DateTime date;
                  if (day is String) {
                    date = parseTurkishDay(day); // Türkçe gün adını DateTime'a çevir
                  } else {
                    throw FormatException('Unsupported date format');
                  }

                  String status = tempStatusMap[date] ?? 'none';

                  if (dates is Map) {
                    Map<String, String> datesMap = Map<String, String>.from(dates);
                    if (datesMap.containsKey(todayString)) {
                      if (status == 'none' || status == 'some') {
                        tempStatusMap[date] = 'some';
                      } else if (status == 'all') {
                        tempStatusMap[date] = 'all';
                      }
                    }
                  }
                } catch (e) {
                  print('Invalid date format for day: $day'); // Handle the invalid date format
                }
              });
            }
          });

          usedMedicinesMap.forEach((date, medicines) {
            if (tempStatusMap[date] == 'some' || tempStatusMap[date] == 'none') {
              tempStatusMap[date] = 'some';
            } else if (tempStatusMap[date] == 'all') {
              tempStatusMap[date] = 'all';
            }
          });

          setState(() {
            medicineStatusMap = tempStatusMap;
          });
        }
      } catch (error) {
        print('Error fetching medicine status: $error');
      }
    }
  }

  DateTime parseTurkishDay(String day) {
    Map<String, int> dayMapping = {
      'Pazartesi': 1,
      'Salı': 2,
      'Çarşamba': 3,
      'Perşembe': 4,
      'Cuma': 5,
      'Cumartesi': 6,
      'Pazar': 7,
    };

    int dayOfWeek = dayMapping[day]!;
    DateTime now = DateTime.now();
    int daysToAdd = (dayOfWeek - now.weekday + 7) % 7;
    DateTime date = now.add(Duration(days: daysToAdd));
    return date;
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return usedMedicinesMap[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents = _getEventsForDay(selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanılan İlaçlar Raporu'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                Color? dayColor;

                if (medicineStatusMap.containsKey(date)) {
                  String status = medicineStatusMap[date]!;
                  if (status == 'all') {
                    dayColor = Colors.green;
                  } else if (status == 'some') {
                    dayColor = Colors.yellow;
                  } else if (status == 'none') {
                    dayColor = Colors.red;
                  }
                }

                if (dayColor != null) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dayColor,
                    ),
                    margin: const EdgeInsets.all(6.0),
                    alignment: Alignment.center,
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          Expanded(
            child: _selectedEvents.isEmpty
                ? Center(child: Text('İlaç kullanılan günü seçin.'))
                : ListView.builder(
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      var event = _selectedEvents[index];
                      return Card(
                        child: ListTile(
                          title: Text(event['name']),
                          subtitle: Text('Kullanım Zamanı: ${event['time']}'),
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
