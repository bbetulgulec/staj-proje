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

class emergency_page extends StatefulWidget {
  const emergency_page({Key? key}) : super(key: key);

  @override
  State<emergency_page> createState() => _emergency_pageState();
}

class _emergency_pageState extends State<emergency_page> {
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
                  MaterialPageRoute(builder: (context) => HomePage()),);
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
                  MaterialPageRoute(builder: (context) => emergency_page()),
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
                  MaterialPageRoute(builder: (context) => Login_page()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleText(),
            SizedBox(height: 20),
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
                // Formu submit etmek için işlemler
                handleSubmit();
              },
              child: Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }

  
void handleSubmit() {
  // Kullanıcı adı ve numarasını Firebase'e kaydetme işlemi
  String emergencyName = userNameController.text.trim();
  String emergencyNumber = userNumberController.text.trim();

  // Şu anki kullanıcıyı al
  User? currentUser = firebaseAuth.currentUser;
  if (currentUser != null) {
    // Kullanıcı verilerini 'users' düğümü altında kaydetmek için referans oluştur
    DatabaseReference userRef = databaseReference.child('users').child(currentUser.uid).child('emergencies').push();
    
    // Kullanıcı bilgilerini Firebase'e kaydet
    userRef.set({
      'emergencyName': emergencyName,
      'emergencyNumber': emergencyNumber,
    }).then((value) {
      // Başarılı kayıt durumunda kullanıcıyı bilgilendirme
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kullanıcı bilgileri başarıyla kaydedildi!"),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      // Hata durumunda kullanıcıyı bilgilendirme
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kullanıcı bilgileri kaydedilirken hata oluştu: $error"),
          duration: Duration(seconds: 2),
        ),
      );
    });
  } else {
    // Kullanıcı oturumu açık değilse uyarı ver
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Oturum açan kullanıcı bulunamadı."),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

  Text titleText() {
    return Text(
      " Acil durum aramaları  ",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: HexColor('#3F51B5'), // replace with your primaryColor
      ),
    );
  }

  Widget customSizeBox() => SizedBox(
        height: 20.0,
      );
}

