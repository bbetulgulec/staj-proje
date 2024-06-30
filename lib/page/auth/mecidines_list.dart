import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:remember_medicine/page/auth/emergencyContacts.dart';
import 'package:remember_medicine/page/auth/home.dart';
import 'package:remember_medicine/page/auth/login.dart';
import 'package:remember_medicine/page/auth/medicines.dart';
import 'package:remember_medicine/page/auth/profile.dart';
import 'package:remember_medicine/page/auth/reports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicinesListPage extends StatefulWidget {
  const MedicinesListPage({super.key});

  @override
  State<MedicinesListPage> createState() => _MedicinesListPageState();
}

class _MedicinesListPageState extends State<MedicinesListPage> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final firebaseAuth = FirebaseAuth.instance;

  Future<void> _deleteMedicine(String userId, String medicineName) async {
    await databaseReference
        .child('users')
        .child(userId)
        .child('medicines')
        .child(medicineName)
        .remove();
  }

  Future<void> _updateMedicine(String userId, String oldMedicineName,
      String newMedicineName, Map<String, dynamic> newMedicineData) async {
    DatabaseReference userRef =
        databaseReference.child('users').child(userId).child('medicines');

    if (oldMedicineName != newMedicineName) {
      // Eski veriyi sil ve yeni isimle ekle
      await userRef.child(newMedicineName).set(newMedicineData);
    } else {
      await userRef.child(oldMedicineName).update(newMedicineData);
    }

    setState(() {}); // Güncelleme sonrası sayfayı yenile
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
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('İlaç Listesi'),
        ),
        body: const Center(),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicinesPage2(
                medicineName: '',
                medicineData: {},
              ),
            ),
          ).then((result) {
            if (result != null) {
              _updateMedicine(user.uid, '', result['name'], result['data']);
            }
          });
        },
        backgroundColor: HexColor(buttonColor),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        title: const Text('İlaç Listesi'),
      ),
      drawer: menuDrawer(context),

      body: Container(
        child: StreamBuilder(
          stream: databaseReference
              .child('users')
              .child(user.uid)
              .child('medicines')
              .onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                  child: Text('Bir hata oluştu: ${snapshot.error}'));
            }

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              Map<dynamic, dynamic> medicines =
                  snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              return ListView.builder(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  String medicineName = medicines.keys.elementAt(index);
                  var medicineData = medicines[medicineName];

                  // medicineData'nın türünü kontrol et
                  if (medicineData is Map<dynamic, dynamic>) {
                    List<String> days = [];
                    Set<String> times = Set<String>();

                    if (medicineData['days'] != null) {
                      (medicineData['days'] as Map).forEach((day, value) {
                        days.add(day);
                        if (value is Map) {
                          value.forEach((date, time) {
                            if (time is List) {
                              times.addAll(
                                  time.map((t) => t.toString()).toList());
                            } else {
                              times.add(time.toString());
                            }
                          });
                        }
                      });
                    }

                    String timesString = times.join(' - ');
return Card(
  elevation: 12.0,
  margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
  child: Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "İlaç Adı: $medicineName",
                    style: TextStyle(fontSize: 18),
                  ),
                  if (days.isNotEmpty)
                    Text("Gün: ${days.first}",
                        style: TextStyle(fontSize: 17)),
                ],
              ),
            ),
            GestureandButton(user, medicineName, medicineData, context),
          ],
        ),
        if (times.isNotEmpty)
          Wrap(
            spacing: 2.0, // Aralarındaki yatay boşluk
            runSpacing: 2.0, // Aralarındaki dikey boşluk
            children: times.map((time) {
              return Chip(
                label: Text(
                  "Saat: $time",
                  style: TextStyle(fontSize: 10),
                ),
              );
            }).toList(),
          ),
      ],
    ),
  ),
);

                  
                  } else {
                    return SizedBox.shrink();
                  }
                },
              );
            }

            return Center(child: Text('İlaç bulunamadı.'));
          },
        ),
      ),
   
    );
  }

  Row GestureandButton(User user, String medicineName,
      Map<dynamic, dynamic> medicineData, BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            var result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedicinesPage2(
                  medicineName: medicineName,
                  medicineData: medicineData,
                ),
              ),
            );
            if (result != null) {
              _updateMedicine(
                  user.uid, medicineName, result['name'], result['data']);
            }
          },
          child: Icon(Icons.edit),
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () async {
            bool? confirmDelete = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'Silmek istediğinize emin misiniz?',
                  style: TextStyle(
                    color: Color.fromARGB(255, 58, 57, 57),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Hayır',
                      style: TextStyle(color: HexColor(buttonColor)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Evet',
                      style: TextStyle(color: HexColor(buttonColor)),
                    ),
                  ),
                ],
              ),
            );
            if (confirmDelete == true) {
              _deleteMedicine(user.uid, medicineName);
            }
          },
        ),
      ],
    );
  }

  Widget customSizeBox() => SizedBox(height: 20.0);

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
              Icons.person_add_alt_1_sharp,
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
              Icons.logout,
              size: 30,
              color: Colors.black45,
            ),
            title: const Text(
              "Çıkış Yap",
              style: TextStyle(
                fontSize: 30,
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
}
