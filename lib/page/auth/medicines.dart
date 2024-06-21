import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:remember_medicine/const/color.dart';

class MedicinesPage2 extends StatefulWidget {
  const MedicinesPage2({super.key});

  @override
  State<MedicinesPage2> createState() => _MedicinesPage2State();
}

class _MedicinesPage2State extends State<MedicinesPage2> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  final TextEditingController timesController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  String selectedDay = '';
  String selectedTime = '';

  final List<String> days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
  final Map<String, List<String>> hours = {
    'Pazartesi': ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00'],
    'Salı': ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00'],
    'Çarşamba': ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00'],
    'Perşembe': ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00'],
    'Cuma': ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00'],
    'Cumartesi': ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00'],
    'Pazar': ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customSizeBox(),
              const Text(
                "Adı :",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: nameController,
                  onSaved: (value) {
                    nameController.text = value!;
                  },
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              customSizeBox(),
              const Text(
                "Hangi günler kullanacaksın:",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedDay.isEmpty ? null : selectedDay,
                  onChanged: (newValue) {
                    setState(() {
                      selectedDay = newValue!;
                      selectedTime = ''; // Gün değiştiğinde saat seçimlerini temizle
                    });
                  },
                  items: days.map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Gün seçiniz",
                  ),
                ),
              ),
              if (selectedDay.isNotEmpty) ...[
                SizedBox(height: 10), // Arada bir boşluk ekleyebiliriz
                Text(
                  "Hangi saatler kullanacaksın :",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedTime.isEmpty ? null : selectedTime,
                    onChanged: (newValue) {
                      setState(() {
                        selectedTime = newValue!;
                      });
                    },
                    items: hours[selectedDay]!.map((time) {
                      return DropdownMenuItem(
                        value: time,
                        child: Text(time),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Saat seçiniz",
                    ),
                  ),
                ),
              ],
              SizedBox(height: 20), // Araya boşluk ekleyebiliriz
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    formKey.currentState!.save();
                    saveMedicine();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor(buttonColor),
                  ),
                  child: const Text(
                    "Ekle",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              SizedBox(height: 20), // Araya biraz boşluk daha ekleyelim
            ],
          ),
        ),
      ),
    );
  }

  Widget customSizeBox() => const SizedBox(height: 20.0);

  void saveMedicine() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      final medicineRef = databaseReference
          .child('users')
          .child(user.uid)
          .child('medicines')
          .child(nameController.text);

      // Seçilen gün ve saat için verileri eklemek
      final dayRef = medicineRef.child('days').child(selectedDay);
      await dayRef.child('times').set(selectedTime);

      // Kullanıcıya başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İlaç bilgileri başarıyla eklendi')),
      );
    }
  }
}
