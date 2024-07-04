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
import 'package:remember_medicine/page/auth/notification.dart';
import 'package:remember_medicine/page/auth/reports.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      DatabaseReference userRef =
          databaseReference.child('users').child(user.uid);
      userRef.once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        setState(() {
          if (snapshot.value != null) {
            Map<dynamic, dynamic> userData =
                snapshot.value as Map<dynamic, dynamic>;
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
      DatabaseReference userRef =
          databaseReference.child('users').child(user.uid);
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
        title: Text(
          "Kullanıcı Bilgilerini Güncelle",
          style: TextStyle(
            fontSize: 15,
            color: Color.fromARGB(255, 58, 57, 57),
          ),
        ),
      ),
      drawer: menuDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: personInfo(),
      ),
    );
  }

  Widget personInfo() {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0, left: 15.0),
      child: ListView(
        children: [
          customTextField("Ad", nameController),
          customTextField(
            "Soyad",
            surnameController,
          ),
          customTextField("E-Mail", emailController),
          customTextField("Telefon", numberController),
          customTextField("Yaş", ageController),
          customTextField("Cinsiyet", genderController),
          customTextField("Kilo", weightController),
          customTextField("Boy", heightController),
          SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: ElevatedButton(
              onPressed: updateUserData,
              child: Text(
                'Güncelle',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                backgroundColor: HexColor(buttonColor),
              ),
            ),
          ),
        ],
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
              "Alarm",
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

  Widget customTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: HexColor(textfieldColor)),
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: HexColor(textfieldColor))),
        ),
      ),
    );
  }

  Widget customSizeBox() => SizedBox(
        height: 12.0,
      );
}
