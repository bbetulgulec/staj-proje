import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:remember_medicine/page/auth/home.dart';
import 'package:remember_medicine/page/auth/login.dart';
import 'package:remember_medicine/page/auth/mecidines_list.dart';
import 'package:remember_medicine/page/auth/profile.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({Key? key}) : super(key: key);

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  late String emergencyName = '';
  late TextEditingController userNameController;
  late TextEditingController userNumberController;

  final formKey = GlobalKey<FormState>();
  final firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    userNameController = TextEditingController();
    userNumberController = TextEditingController();
  }

  @override
  void dispose() {
    userNameController.dispose();
    userNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = firebaseAuth.currentUser;

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
            customSizeBox(),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login_page()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  // Kayıtlı acil durum numaralarını listeleyen kısım
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kayıtlı Acil Durum Numaraları",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: StreamBuilder(
                            stream: databaseReference.child('users').child(user!.uid).child('emergencies').onValue,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
                              }

                              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                                Map<dynamic, dynamic> emergencies = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                                return ListView.builder(
                                  itemCount: emergencies.length,
                                  itemBuilder: (context, index) {
                                    String key = emergencies.keys.elementAt(index);
                                    var emergency = emergencies[key];

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
                                                Text("Adı: ${emergency['emergencyName']}"),
                                                Text("Numarası: ${emergency['emergencyNumber']}"),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    _updateEmergency(user.uid, key, emergency);
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
                                                      _deleteEmergency(user.uid, key);
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }

                              return Center(child: Text('Kayıtlı acil durum numarası yok.'));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(color: Colors.black),
                  // Yeni numara ekleme formu
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Yeni Acil Durum Numarası Ekle",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kullanıcı Adı",
                              style: TextStyle(fontSize: 20),
                            ),
                            TextFormField(
                              controller: userNameController,
                              decoration: InputDecoration(
                                hintText: "Kullanıcı Adınızı Girin",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Kullanıcı Numarası",
                              style: TextStyle(fontSize: 20),
                            ),
                            TextFormField(
                              controller: userNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: "Kullanıcı Numaranızı Girin",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                handleSubmit();
                              },
                              child: Text("Kaydet"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleSubmit() {
    String emergencyName = userNameController.text.trim();
    String emergencyNumber = userNumberController.text.trim();

    User? currentUser = firebaseAuth.currentUser;
    if (currentUser != null) {
      DatabaseReference userRef = databaseReference.child('users').child(currentUser.uid).child('emergencies').push();

      userRef.set({
        'emergencyName': emergencyName,
        'emergencyNumber': emergencyNumber,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Kullanıcı bilgileri başarıyla kaydedildi!"),
            duration: Duration(seconds: 2),
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Kullanıcı bilgileri kaydedilirken hata oluştu: $error"),
            duration: Duration(seconds: 2),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Oturum açan kullanıcı bulunamadı."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _updateEmergency(String userId, String key, dynamic emergency) {
    userNameController.text = emergency['emergencyName'];
    userNumberController.text = emergency['emergencyNumber'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Acil Durum Bilgilerini Güncelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: userNameController,
              decoration: InputDecoration(labelText: 'Kullanıcı Adı'),
            ),
            TextFormField(
              controller: userNumberController,
              decoration: InputDecoration(labelText: 'Kullanıcı Numarası'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              databaseReference.child('users').child(userId).child('emergencies').child(key).set({
                'emergencyName': userNameController.text,
                'emergencyNumber': userNumberController.text,
              }).then((_) {
                Navigator.of(context).pop();
              });
            },
            child: Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _deleteEmergency(String userId, String key) {
    databaseReference.child('users').child(userId).child('emergencies').child(key).remove();
  }

  Text titleText() {
    return Text(
      "Acil Durum Aramaları",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: HexColor('#3F51B5'),
      ),
    );
  }

  Widget customSizeBox() => SizedBox(
        height: 20.0,
      );
}
