import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:remember_medicine/page/auth/emergencyContacts.dart';
import 'package:remember_medicine/page/auth/home.dart';
import 'package:remember_medicine/page/auth/login.dart';
import 'package:remember_medicine/page/auth/medicines.dart';
import 'package:remember_medicine/page/auth/profile.dart'; // Burada medicines.dart dosyasını import ediyoruz.

class MedicinesListPage extends StatefulWidget {
  const MedicinesListPage({super.key});

  @override
  State<MedicinesListPage> createState() => _MedicinesListPageState();
}

class _MedicinesListPageState extends State<MedicinesListPage> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final firebaseAuth = FirebaseAuth.instance;

  Future<void> _deleteMedicine(String userId, String medicineName) async {
    await databaseReference.child('users').child(userId).child('medicines').child(medicineName).remove();
  }

  void _updateMedicine(String userId, String medicineName, Map<dynamic, dynamic> medicineData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicinesPage2(
          medicineName: medicineName,
          medicineData: medicineData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      // Kullanıcı oturum açmamışsa bir bildirim gösterilebilir
      return Scaffold(
        appBar: AppBar(
          title: const Text('İlaç Listesi'),
        ),
        body: const Center(
          child: Text('Lütfen giriş yapın'),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MedicinesPage2(
                medicineName: '', // Yeni ilaç eklemek için boş string gönderebilirsiniz.
                medicineData: {}, // Yeni ilaç eklemek için boş map gönderebilirsiniz.
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('İlaç Listesi'),
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
                  MaterialPageRoute(builder: (context) => HomePage()),);
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
                  MaterialPageRoute(builder: (context) => MedicinesListPage()),);
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
              onTap: () {},
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
                  MaterialPageRoute(builder: (context) => emergency_page()),);
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
                  MaterialPageRoute(builder: (context) => ProfilePage()),);
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
                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login_page()));
              },
            ),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: StreamBuilder(
          stream: databaseReference.child('users').child(user.uid).child('medicines').onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
            }

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              Map<dynamic, dynamic> medicines = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              return ListView.builder(
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  String medicineName = medicines.keys.elementAt(index);
                  var medicineData = medicines[medicineName];

                  // medicineData'nın türünü kontrol et
                  if (medicineData is Map<dynamic, dynamic>) {
                    return Card(
                      elevation: 5.0,
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("İlaç Adı: $medicineName"),
                                Text("Bilgiler: $medicineData"),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _updateMedicine(user.uid, medicineName, medicineData);
                                  },
                                  child: Icon(Icons.edit),
                                ),
                                SizedBox(width: 8.0),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    bool? confirmDelete = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Silmek istediğinize emin misiniz?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: Text('Hayır'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: Text('Evet'),
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
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(); // Boş widget döndür, medicineData beklenen türde değilse
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
  Widget customSizeBox() => SizedBox(
        height: 20.0,
      );
}
