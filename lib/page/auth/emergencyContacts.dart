import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:remember_medicine/page/auth/home.dart';
import 'package:remember_medicine/page/auth/login.dart';
import 'package:remember_medicine/page/auth/mecidines_list.dart';
import 'package:remember_medicine/page/auth/notification.dart';
import 'package:remember_medicine/page/auth/profile.dart';
import 'package:remember_medicine/page/auth/reports.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Acil Durum Kullanıcısı ",
          style: TextStyle(
            fontSize: 15,
            color: Color.fromARGB(255, 58, 57, 57),
          ),
        ),
      ),
      drawer: menuDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              emergencyAdd(),
              SizedBox(height: 20),
              emergencyList(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget emergencyAdd() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Yeni Acil Durum Numarası Ekle",
          style: TextStyle(
            color: Color.fromARGB(255, 58, 57, 57),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        customSizeBox(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kullanıcı Adı",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 58, 57, 57),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextFormField(
                controller: userNameController,
                decoration: InputDecoration(
                  hintText: "Kullanıcı Adınızı Girin",
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: HexColor(backgroundColor))),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Kullanıcı Numarası",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 58, 57, 57),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextFormField(
                controller: userNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Kullanıcı Numaranızı Girin",
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: HexColor(backgroundColor))),
                ),
              ),
            ),
            customSizeBox(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor(buttonColor),
                  padding: EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  handleSubmit();
                },
                child: Text(
                  "Kaydet",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget emergencyList(User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Kayıtlı Acil Durum Numaraları",
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 58, 57, 57),
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 200,
          child: StreamBuilder(
            stream: databaseReference
                .child('users')
                .child(user!.uid)
                .child('emergencies')
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
                Map<dynamic, dynamic> emergencies =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: emergencies.length,
                  itemBuilder: (context, index) {
                    String key = emergencies.keys.elementAt(index);
                    var emergency = emergencies[key];

                    return Card(
                      elevation: 12.0,
                      margin:
                          EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Adı: ${emergency['emergencyName']}"),
                                Text(
                                    "Numarası: ${emergency['emergencyNumber']}"),
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
                                        title: Text(
                                            'Silmek istediğinize emin misiniz?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: Text('Hayır'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
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
              Icons.alarm,
              size: 22,
              color: Colors.black45,
            ),
            title: const Text(
              "Alarmlar",
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Notification_page()),
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

  Future<void> handleSubmit() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      await _saveEmergency();
    }
  }

  Future<void> _saveEmergency() async {
    String userId = firebaseAuth.currentUser!.uid;

    await databaseReference
        .child('users')
        .child(userId)
        .child('emergencies')
        .push()
        .set({
      'emergencyName': userNameController.text,
      'emergencyNumber': userNumberController.text,
    });

    userNameController.clear();
    userNumberController.clear();

    setState(() {});
  }

  Future<void> _updateEmergency(
      String userId, String key, dynamic emergency) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Acil Durum Numarasını Güncelle'),
          content: Column(
            children: [
              TextField(
                controller: userNameController
                  ..text = emergency['emergencyName'],
                decoration: InputDecoration(labelText: 'Adı'),
              ),
              TextField(
                controller: userNumberController
                  ..text = emergency['emergencyNumber'],
                decoration: InputDecoration(labelText: 'Numarası'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await databaseReference
                    .child('users')
                    .child(userId)
                    .child('emergencies')
                    .child(key)
                    .update({
                  'emergencyName': userNameController.text,
                  'emergencyNumber': userNumberController.text,
                });
                userNameController.clear();
                userNumberController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEmergency(String userId, String key) async {
    await databaseReference
        .child('users')
        .child(userId)
        .child('emergencies')
        .child(key)
        .remove();
    setState(() {});
  }

  SizedBox customSizeBox() {
    return SizedBox(height: 12.0);
  }
}
