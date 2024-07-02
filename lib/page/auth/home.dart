import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:remember_medicine/page/auth/emergencyContacts.dart';
import 'package:remember_medicine/page/auth/login.dart';
import 'package:remember_medicine/page/auth/mecidines_list.dart';
import 'package:remember_medicine/page/auth/profile.dart';
import 'package:remember_medicine/page/auth/reports.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth mAuth = FirebaseAuth.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  String userName = '';
  List<Map<String, dynamic>> todayMedicines = [];
  Set<String> usedMedicines = {};
  int todayTotalDoses = 0;

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

        List<Map<String, dynamic>> medicinesForToday = [];
        int totalDoses = 0;

        if (snapshot.value != null && snapshot.value is Map) {
          Map<dynamic, dynamic> medicinesData =
              snapshot.value as Map<dynamic, dynamic>;

          medicinesData.forEach((medicineName, medicineDetails) {
            if (medicineDetails is Map && medicineDetails['days'] is Map) {
              Map<dynamic, dynamic> daysData =
                  medicineDetails['days'] as Map<dynamic, dynamic>;

              daysData.forEach((day, dates) {
                if (dates is Map && dates.containsKey(todayString)) {
                  var timeValue = dates[todayString];
                  List<String> times = [];

                  if (timeValue is List) {
                    times = List<String>.from(timeValue);
                  }

                  medicinesForToday.add({
                    'name': medicineName,
                    'times': times,
                  });

                  totalDoses += times.length;
                }
              });
            }
          });
        }

        setState(() {
          todayMedicines = medicinesForToday;
          todayTotalDoses = totalDoses;
        });
      } catch (error) {
        print('İlaç verileri getirilirken hata oluştu: $error');
      }
    }
  }

  void _fetchUserName() async {
    User? currentUser = mAuth.currentUser;
    if (currentUser != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(currentUser.uid);
      userRef.once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        setState(() {
          if (snapshot.value != null) {
            Map<dynamic, dynamic> userData =
                snapshot.value as Map<dynamic, dynamic>;
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
        Map<dynamic, dynamic> usedMedicinesData =
            snapshot.value as Map<dynamic, dynamic>;
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

  Future<void> saveUsedMedicines(String medicineName, String time) async {
    User? user = mAuth.currentUser;
    if (user != null) {
      DateTime now = DateTime.now();
      String todayString = '${now.year}-${now.month}-${now.day}';

      final usedMedicineRef = databaseReference
          .child('users')
          .child(user.uid)
          .child('todayOfUsedMedicine')
          .child(todayString)
          .child('$medicineName-$time');

      await usedMedicineRef.set({
        'time': time,
      });

      setState(() {
        usedMedicines.add('$medicineName-$time');
      });

      // Güncellenmiş ilerleme oranını hesapla
      double progress = calculateProgress();

      // Check if all doses are used
      if (progress >= 1.0) {
        // All doses are used
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Bugün almanız gereken tüm ilaçları aldınız!'),
          duration: Duration(seconds: 2),
        ));
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

  double calculateProgress() {
    int totalTimes = todayMedicines.fold<int>(
        0, (sum, medicine) => sum + (medicine['times'] as List).length);
    int usedTimes = usedMedicines.length;

    return totalTimes > 0 ? usedTimes / totalTimes : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    double progress = calculateProgress();
    progress = progress.clamp(0.0, 1.0);

    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Anasayfa"),
      ),
      drawer: menuDrawer(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              textName(),
              customSizeBox(),
              Expanded(
                child: CardList(screenSize),
              ),
              customSizeBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: textTotalMedicines(),
                  ),
                  Flexible(
                    flex: 1,
                    child: CircularProgressBar(progress: progress),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textTotalMedicines() {
    return Text(
      "Toplam İlaç Sayısı: $todayTotalDoses",
      style: TextStyle(
        fontSize: 25,
        color: Color.fromARGB(255, 58, 57, 57),
      ),
    );
  }

  Widget CircularProgressBar({required double progress}) {
    return SleekCircularSlider(
      appearance: CircularSliderAppearance(
        size: 150, // Boyutu buradan ayarlayabilirsiniz
        customColors: CustomSliderColors(
          trackColor: Color.fromARGB(255, 241, 230, 230),
          progressBarColor: Color.fromARGB(255, 9, 206, 45),
          shadowColor: Color.fromARGB(255, 5, 136, 30),
          dotColor: Color.fromARGB(255, 14, 12, 12),
        ),
        infoProperties: InfoProperties(
          mainLabelStyle: TextStyle(
            color: Color.fromARGB(255, 12, 11, 11),
            fontSize: 15,
          ),
        ),
        startAngle: 10,
        angleRange: 360,
      ),
      min: 0,
      max: 100,
      initialValue: progress * 100,
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
                fontSize: 25,
                color: Colors.black,
              ),
            ),
          ),
          customSizeBox(),
          ListTile(
            leading: Icon(
              Icons.home,
              size: 22,
              color: Colors.black45,
            ),
            title: const Text(
              "Anasayfa",
              style: TextStyle(
                fontSize: 22,
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
              size: 22,
              color: Colors.black45,
            ),
            title: const Text(
              "İlaç Listesi",
              style: TextStyle(
                fontSize: 22,
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
              size: 22,
              color: Colors.black45,
            ),
            title: const Text(
              "Takvim",
              style: TextStyle(
                fontSize: 22,
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
              Icons.person_add_alt_1_sharp,
              size: 22,
              color: Colors.black45,
            ),
            title: const Text(
              "Acil Durum",
              style: TextStyle(
                fontSize: 22,
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
              size: 22,
              color: Colors.black45,
            ),
            title: const Text(
              "Profil",
              style: TextStyle(
                fontSize: 22,
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
              Icons.logout,
              size: 22,
              color: Colors.black45,
            ),
            title: const Text(
              "Çıkış Yap",
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              signOut(context);
            },
          ),
          customSizeBox(),
        ],
      ),
    );
  }

  SizedBox customSizeBox() => SizedBox(height: 12);

  Expanded CardList(Size screenSize) {
    return Expanded(
      child: ListView.builder(
        itemCount: todayMedicines.length,
        itemBuilder: (context, index) {
          String medicineName = todayMedicines[index]['name'];
          List<String> medicineTimes = todayMedicines[index]['times'];
          bool allTimesUsed = medicineTimes
              .every((time) => usedMedicines.contains('$medicineName-$time'));

          return Card(
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, right: 5.0,left: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        medicineName,
                        style: TextStyle(fontSize: 17),
                      ),
                      if (allTimesUsed)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, color: Colors.green, size: 17),
                            SizedBox(width: 8),
                            Text(
                              'İlaç tamamlandı',
                              style:
                                  TextStyle(color: Colors.green, fontSize: 15),
                            ),
                          ],
                        )
                      else
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            for (String time in medicineTimes) {
                              if (!usedMedicines
                                  .contains('$medicineName-$time')) {
                                saveUsedMedicines(medicineName, time);
                                break;
                              }
                            }
                            // İlerleme oranını güncelle
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: medicineTimes.map((time) {
                        bool isUsed =
                            usedMedicines.contains('$medicineName-$time');
                        return Chip(
                          label: Text(time),
                          backgroundColor: isUsed ? Colors.green : Colors.red,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget textName() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Merhaba ${userName.isNotEmpty ? userName.toUpperCase() : ' '} \nBugün Alacağın İlaçlar:",
            style: TextStyle(
              fontSize: 17,
              color: Color.fromARGB(255, 58, 57, 57),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }


}