import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:remember_medicine/page/auth/emergencyContacts.dart';
import 'package:remember_medicine/page/auth/home.dart';
import 'package:remember_medicine/page/auth/login.dart';
import 'package:remember_medicine/page/auth/mecidines_list.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      DatabaseReference userRef = databaseReference.child('users').child(user.uid);
      userRef.once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        setState(() {
          if (snapshot.value != null) {
            Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
            nameController.text = userData['name'];
            surnameController.text = userData['surname'];
            emailController.text = userData['email'];
            numberController.text = userData['number'];
            ageController.text = userData['age'];
            genderController.text = userData['gender'];
            weightController.text = userData['weight'];
            heightController.text = userData['height'];
          } else {
            nameController.text = 'isim yok';
            surnameController.text = 'soyisim yok';
            emailController.text = 'mail yok';
            numberController.text = 'numara yok';
            ageController.text = 'yas yok';
            genderController.text = 'cinsiyet yok';
            weightController.text = 'kilo yok';
            heightController.text = 'boy yok';
          }
        });
      }).catchError((error) {
        print('Veri bulunamadı: $error');
      });
    }
  }

  void updateUserData() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      DatabaseReference userRef = databaseReference.child('users').child(user.uid);
      await userRef.update({
        'name': nameController.text,
        'surname': surnameController.text,
        'email': emailController.text,
        'number': numberController.text,
        'age': ageController.text,
        'gender': genderController.text,
        'weight': weightController.text,
        'height': heightController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Kullanıcı bilgileri güncellendi'),
      ));
    }
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
        padding: const EdgeInsets.all(30.0),
        child: ListView(
          children: [
            customTextField("Ad", nameController),
            customTextField("Soyad", surnameController),
            customTextField("E-Mail", emailController),
            customTextField("Telefon", numberController),
            customTextField("Yaş", ageController),
            customTextField("Cinsiyet", genderController),
            customTextField("Kilo", weightController),
            customTextField("Boy", heightController),
            SizedBox(height: 20.0),
            ElevatedButton(
              
              onPressed: updateUserData,
              child: Text('Güncelle', style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),),
              style: ElevatedButton.styleFrom(
              backgroundColor: HexColor(buttonColor),
              
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
