import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:remember_medicine/page/auth/emergencyContacts.dart';
import 'package:remember_medicine/page/auth/login.dart';
import 'package:remember_medicine/page/auth/mecidines_list.dart';
import 'package:remember_medicine/page/auth/profile.dart';
import 'package:remember_medicine/page/auth/reports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth mAuth = FirebaseAuth.instance;
  late DatabaseReference userRef;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  String userName = '';
  List<Map<String, String>> todayMedicines = [];
  Set<String> usedMedicines = {};
  int todayMedicinesCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
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
          .child('medicines');

      try {
        DatabaseEvent event = await medicationRef.once();
        DataSnapshot snapshot = event.snapshot;

        DateTime now = DateTime.now();
        String todayString = '${now.year}-${now.month}-${now.day}';

        List<Map<String, String>> medicinesForToday = [];

        if (snapshot.value != null && snapshot.value is Map) {
          Map<dynamic, dynamic> medicinesData = snapshot.value as Map<dynamic, dynamic>;

          medicinesData.forEach((medicineName, medicineDetails) {
            if (medicineDetails is Map && medicineDetails['days'] is Map) {
              Map<dynamic, dynamic> daysData = medicineDetails['days'] as Map<dynamic, dynamic>;

              daysData.forEach((day, dates) {
                if (dates is Map) {
                  Map<String, String> datesMap = Map<String, String>.from(dates);
                  if (datesMap.containsKey(todayString)) {
                    medicinesForToday.add({
                      'name': medicineName,
                      'time': datesMap[todayString]!,
                    });
                  }
                }
              });
            }
          });
        }

        setState(() {
          todayMedicines = medicinesForToday;
          todayMedicinesCount = medicinesForToday.length; // Günlük ilaç sayısını güncelle
        });
      } catch (error) {
        print('İlaç verileri getirilirken hata oluştu: $error');
      }
    }
  }

  void _fetchUserName() async {
    User? currentUser = mAuth.currentUser;
    if (currentUser != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(currentUser.uid);
      userRef.once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        setState(() {
          if (snapshot.value != null) {
            Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
            userName = userData['name'];
          } else {
            userName = 'User data not found';
          }
        });
      }).catchError((error) {
        print('Failed to fetch user data: $error');
      });
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

  Future<void> saveUsedMedicines(String medicineName, String medicineTime) async {
    User? user = mAuth.currentUser;
    if (user != null) {
      DateTime now = DateTime.now();
      String todayString = '${now.year}-${now.month}-${now.day}';

      final usedMedicineRef = databaseReference
          .child('users')
          .child(user.uid)
          .child('todayOfUsedMedicine')
          .child(todayString)
          .child(medicineName);

      await usedMedicineRef.set({
        'time': medicineTime,
      });

      setState(() {
        usedMedicines.add(medicineName);
      });
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
        backgroundColor: HexColor(backgroundColor),
        title: Center(
          child: Text(
            "ANASAYFA",
            style: TextStyle(
              fontSize: 30,
              color: HexColor(primaryColor),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: HexColor(backgroundColor),
        child: ListView(
          children: [
            Center(
              child: Text(
                "Menü",
                style: TextStyle(
                  fontSize: 30,
                  color: HexColor(primaryColor),
                ),
              ),
            ),
            customSizeBox(),
            ListTile(
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
            ListTile(
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
              title: const Text(
                "Raporlar",
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Merhaba ${userName.isNotEmpty ? userName.toUpperCase() : 'Loading...'}",
                      style: TextStyle(
                        fontSize: 35,
                        color: HexColor(primaryColor),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                customSizeBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Bugün alacağın ilaçlar:",
                      style: TextStyle(
                        fontSize: 35,
                        color: HexColor(primaryColor),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                customSizeBox(),
                Expanded(
                  child: ListView.builder(
                    itemCount: todayMedicines.length,
                    itemBuilder: (context, index) {
                      String medicineName = todayMedicines[index]['name']!;
                      bool isUsed = usedMedicines.contains(medicineName);
                      return Card(
                        child: ListTile(
                          title: Text(medicineName),
                          subtitle: Text('Saat: ${todayMedicines[index]['time']}'),
                          trailing: isUsed
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check, color: Colors.green),
                                    SizedBox(width: 8),
                                    Text(
                                      'İlaç kullanıldı',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ],
                                )
                              : IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    saveUsedMedicines(medicineName, todayMedicines[index]['time']!);
                                  },
                                ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20.0), // Araya boşluk ekliyoruz
                Text(
                  "Toplam İlaç Sayısı: $todayMedicinesCount",
                  style: TextStyle(
                    fontSize: 30,
                    color: HexColor(primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget customSizeBox() => const SizedBox(
        height: 20.0,
      );
}
