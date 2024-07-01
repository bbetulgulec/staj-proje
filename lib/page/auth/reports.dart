import 'package:flutter/material.dart';
import 'package:remember_medicine/page/auth/emergencyContacts.dart';
import 'package:remember_medicine/page/auth/home.dart';
import 'package:remember_medicine/page/auth/login.dart';
import 'package:remember_medicine/page/auth/mecidines_list.dart';
import 'package:remember_medicine/page/auth/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Map<String, dynamic>> _selectedEvents = [];
  List<Map<String, dynamic>> todayMedicines = [];
  Set<String> usedMedicines = {};
  int todayMedicinesCount = 0;

  final FirebaseAuth mAuth = FirebaseAuth.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    fetchTodayMedicines();
    fetchUsedMedicines();
  }

  void fetchTodayMedicines() async {
    User? currentUser = mAuth.currentUser;
    if (currentUser != null) {
      DatabaseReference medicationRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(currentUser.uid)
          .child('mounthMedicine');

      try {
        DatabaseEvent event = await medicationRef.once();
        DataSnapshot snapshot = event.snapshot;

        DateTime now = DateTime.now();
        String todayString = '${now.year}-${now.month}-${now.day}';

        List<Map<String, dynamic>> medicinesForToday = [];

        if (snapshot.value != null && snapshot.value is Map) {
          Map<dynamic, dynamic> medicinesData = snapshot.value as Map<dynamic, dynamic>;

          medicinesData.forEach((day, medicineDetails) {
            if (medicineDetails is Map && day == todayString) {
              medicineDetails.forEach((medicineName, time) {
                medicinesForToday.add({
                  'name': medicineName,
                  'time': time,
                });
              });
            }
          });
        }

        setState(() {
          todayMedicines = medicinesForToday;
          todayMedicinesCount = medicinesForToday.length;
        });
      } catch (error) {
        print('İlaç verileri getirilirken hata oluştu: $error');
      }
    }
  }

  Future<void> fetchUsedMedicines() async {
    User? currentUser = mAuth.currentUser;
    if (currentUser != null) {
      DateTime now = DateTime.now();
      String todayString = '${now.year}-${now.month}-${now.day}';

      DatabaseReference usedMedicinesRef = databaseReference
          .child('users')
          .child(currentUser.uid)
          .child('todayOfUsedMedicine')
          .child(todayString);

      DatabaseEvent event = await usedMedicinesRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map) {
        Map<dynamic, dynamic> usedMedicinesData = snapshot.value as Map<dynamic, dynamic>;
        Set<String> usedMedicinesSet = Set<String>();

        usedMedicinesData.forEach((medicineName, medicineDetails) {
          usedMedicinesSet.add(medicineName);
        });

        setState(() {
          usedMedicines = usedMedicinesSet;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUsedMedicinesForDay(DateTime day) async {
    User? currentUser = mAuth.currentUser;
    List<Map<String, dynamic>> eventsForDay = [];
    if (currentUser != null) {
      String dayString = '${day.year}-${day.month}-${day.day}';

      DatabaseReference usedMedicinesRef = databaseReference
          .child('users')
          .child(currentUser.uid)
          .child('todayOfUsedMedicine')
          .child(dayString);

      DatabaseEvent event = await usedMedicinesRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map) {
        Map<dynamic, dynamic> usedMedicinesData = snapshot.value as Map<dynamic, dynamic>;

        usedMedicinesData.forEach((medicineName, medicineDetails) {
          eventsForDay.add({
            'name': medicineName,
            'time': (medicineDetails as Map<dynamic, dynamic>)['time'],
          });
        });
      }
    }
    return eventsForDay;
  }

  Future<Color> _getColorForDay(DateTime day) async {
    String dayString = '${day.year}-${day.month}-${day.day}';
    if (dayString == '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}') {
      if (usedMedicines.length == todayMedicinesCount && todayMedicinesCount > 0) {
        return Colors.green;
      } else if (usedMedicines.isNotEmpty) {
        return Colors.yellow;
      } else {
        return Colors.red;
      }
    } else if (day.isAfter(DateTime.now())) {
      return Color.fromARGB(255, 214, 211, 211); 
    } 
    else {
      DatabaseReference dayRef = databaseReference
          .child('users')
          .child(mAuth.currentUser!.uid)
          .child('todayOfUsedMedicine')
          .child(dayString);

      DatabaseEvent event = await dayRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map) {
        return Colors.green;
      } else {
        return Colors.red;
      }
    }
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Login_page()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanılan İlaçlar Raporu'),
      ),
      drawer: menuDrawer(context),
      body: Column(
        children: [
          Calender(),
          getTheMedicine(),
        ],
      ),
    );
  }

  Widget getTheMedicine() {
    return Expanded(
      child: _selectedEvents.isEmpty
          ? const Center(child: Text('Seçilen günde ilaç kullanımı yok'))
          : ListView.builder(
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) {
                final event = _selectedEvents[index];
                final isUsed = usedMedicines.contains(event['name']);
                return Card(
                  elevation: 12.0,
                  margin: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  child: ListTile(
                    title: Text(event['name']),
                    subtitle: Wrap(
                      spacing: 8.0,
                      children: event['time']
                          .split(',')
                          .map<Widget>((time) => Chip(
                                label: Text(time),
                                backgroundColor: isUsed ? Colors.green : Colors.red,
                              ))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Drawer menuDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Center(
            child: Text(
              "Menü",
              style: TextStyle(
                fontSize: 30,
                color: Colors.black,
              ),
            ),
          ),
          customSizeBox(),
          ListTile(
            leading: Icon(
              Icons.home,
              size: 30,
              color: Colors.black45,
            ),
            title: const Text(
              "Anasayfa",
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          customSizeBox(),
          ListTile(
            leading: Icon(
              Icons.library_books,
              size: 30,
              color: Colors.black45,
            ),
            title: const Text(
              "İlaç Listesi",
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MedicinesListPage()),
              );
            },
          ),
          customSizeBox(),
          ListTile(
            leading: Icon(
              Icons.calendar_month,
              size: 30,
              color: Colors.black45,
            ),
            title: const Text(
              "Takvim",
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ReportsPage()),
              );
            },
          ),
          customSizeBox(),
          ListTile(
            leading: Icon(
              Icons.emergency,
              size: 30,
              color: Colors.black45,
            ),
            title: const Text(
              "Acil Durum",
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EmergencyPage()),
              );
            },
          ),
          customSizeBox(),
          ListTile(
            leading: Icon(
              Icons.person,
              size: 30,
              color: Colors.black45,
            ),
            title: const Text(
              "Profil",
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          customSizeBox(),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              size: 30,
              color: Colors.black45,
            ),
            title: const Text(
              "Çıkış",
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              signOut(context);
            },
          ),
        ],
      ),
    );
  }

  TableCalendar<dynamic> Calender() {
    return TableCalendar(
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        _fetchUsedMedicinesForDay(selectedDay).then((events) {
          setState(() {
            _selectedEvents = events;
          });
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          return FutureBuilder<Color>(
            future: _getColorForDay(date),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  margin: const EdgeInsets.all(6.0),
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              } else if (snapshot.hasError) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  margin: const EdgeInsets.all(6.0),
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              } else {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: snapshot.data,
                  ),
                  margin: const EdgeInsets.all(6.0),
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }
            },
          );
        },
        todayBuilder: (context, date, _) {
          return FutureBuilder<Color>(
            future: _getColorForDay(date),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  margin: const EdgeInsets.all(6.0),
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              } else if (snapshot.hasError) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  margin: const EdgeInsets.all(6.0),
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              } else {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: snapshot.data,
                  ),
                  margin: const EdgeInsets.all(6.0),
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }
            },
          );
        },
        
        selectedBuilder: (context, date, _) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2.0),
            ),
            margin: const EdgeInsets.all(6.0),
            alignment: Alignment.center,
            child: Text(
              date.day.toString(),
              style: const TextStyle(color: Colors.black),
            ),
          );
        },
      ),
    );
  }

  Widget customSizeBox() => SizedBox(
    height: 50.0,
  );
}
