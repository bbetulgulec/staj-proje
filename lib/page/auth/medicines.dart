import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:remember_medicine/const/color.dart';

class MedicinesPage2 extends StatefulWidget {
  final String medicineName;
  final Map<dynamic, dynamic> medicineData;

  const MedicinesPage2({Key? key, required this.medicineName, required this.medicineData}) : super(key: key);

  @override
  State<MedicinesPage2> createState() => _MedicinesPage2State();
}

class _MedicinesPage2State extends State<MedicinesPage2> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController timesController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  String selectedDay = '';
  List<String> selectedTimes = [];

  final List<String> days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
  final List<String> hours = ['08:00', '10:00', '12:00', '14:00', '21:47','16:00','10:25', '11:20', '18:00', '20:00'];

  @override
  void initState() {
    super.initState();
    nameController.text = widget.medicineName;
    selectedDay = getFirstDayFromMedicineData();
    selectedTimes = getFirstTimesFromMedicineData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İlaç Güncelle', style: TextStyle(color: Color.fromARGB(255, 58, 57, 57))),
      ),
      body: SingleChildScrollView(
        child: Container(
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
                    color: Color.fromARGB(255, 58, 57, 57),
                    fontSize: 20,
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
                  "Hangi gün kullanacaksın:",
                  style: TextStyle(
                    color: Color.fromARGB(255, 58, 57, 57),
                    fontSize: 20,
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
                customSizeBox(),
                const Text(
                  "Günde kaç defa alacaksın :",
                  style: TextStyle(
                    color: Color.fromARGB(255, 58, 57, 57),
                    fontSize: 20,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: timesController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        int times = int.tryParse(value) ?? 0;
                        selectedTimes = List.generate(times, (index) => '');
                      });
                    },
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                customSizeBox(),
                const Text(
                  "Hangi saatlerde kullanacaksın:",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                ...List.generate(selectedTimes.length, (index) {
                  return Container(
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedTimes[index].isEmpty ? null : selectedTimes[index],
                      onChanged: (newValue) {
                        setState(() {
                          selectedTimes[index] = newValue!;
                        });
                      },
                      items: hours.map((time) {
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
                  );
                }),
                customSizeBox(),
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
                      "Güncelle",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customSizeBox() => const SizedBox(height: 20.0);

  void saveMedicine() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      final newMedicineRef = databaseReference
          .child('users')
          .child(user.uid)
          .child('medicines')
          .child(nameController.text);

      // Yeni ilaç verisini hazırla
      Map<String, dynamic> medicineData = Map<String, dynamic>.from(widget.medicineData);
      medicineData['days'] ??= {};

      DateTime now = DateTime.now();
      Map<String, List<String>> monthDates = {};
      for (int i = 0; i < 30; i++) {
        DateTime date = now.add(Duration(days: i));
        if (date.weekday == days.indexOf(selectedDay) + 1) {
          String dateString = '${date.year}-${date.month}-${date.day}';
          monthDates[dateString] = selectedTimes;
        }
      }
      (medicineData['days'] as Map)[selectedDay] = monthDates;

      // Yeni ilaç verisini güncelle veya ekle
      await newMedicineRef.set(medicineData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İlaç bilgileri başarıyla güncellendi')),
      );

      Navigator.pop(context, {'name': nameController.text, 'data': medicineData});
    }
  }

  String getFirstDayFromMedicineData() {
    if (widget.medicineData.containsKey('days') && (widget.medicineData['days'] as Map).isNotEmpty) {
      return (widget.medicineData['days'] as Map).keys.first;
    }
    return '';
  }

  List<String> getFirstTimesFromMedicineData() {
    if (widget.medicineData.containsKey('days') &&
        (widget.medicineData['days'] as Map).containsKey(selectedDay) &&
        (widget.medicineData['days'][selectedDay] as Map).isNotEmpty) {
      return (widget.medicineData['days'][selectedDay] as Map).values.first.cast<String>().toList();
    }
    return [];
  }
}