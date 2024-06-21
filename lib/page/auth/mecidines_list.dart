import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:remember_medicine/page/auth/medicines.dart'; // Burada medicines.dart dosyasını import ediyoruz.

class MedicinesListPage extends StatefulWidget {
  const MedicinesListPage({super.key});

  @override
  State<MedicinesListPage> createState() => _MedicinesListPageState();
}

class _MedicinesListPageState extends State<MedicinesListPage> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final firebaseAuth = FirebaseAuth.instance;

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
              builder: (context) => const MedicinesPage2(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('İlaç Listesi'),
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
                  if (medicineData is String) {
                    return Card(
                      elevation: 5.0,
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("İlaç Adı: $medicineName"),
                            Text("Bilgiler: $medicineData"),
                          ],
                        ),
                      ),
                    );
                  } else if (medicineData is Map<dynamic, dynamic>) {
                    return Card(
                      elevation: 5.0,
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("İlaç Adı: $medicineName"),
                            ...medicineData['days'].entries.map((entry) {
                              String day = entry.key;
                              String time = entry.value['times'];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: Text("Günü: $day, Saati: $time"),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Card(
                      elevation: 5.0,
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("İlaç Adı: $medicineName"),
                            Text("Bilinmeyen veri formatı"),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            } else {
              return Center(child: Text('Kayıtlı ilaç yok'));
            }
          },
        ),
      ),
    );
  }
}
