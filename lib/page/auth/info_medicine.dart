import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:remember_medicine/page/auth/home.dart';
import 'package:remember_medicine/page/auth/login.dart';

class InfoMedicine extends StatefulWidget {
  const InfoMedicine({Key? key}) : super(key: key);

  @override
  State<InfoMedicine> createState() => _InfoMedicineState();
}

class _InfoMedicineState extends State<InfoMedicine> {
  int valueMedicine = 0;
  int valueAllergy = 0;
  int valueBloodPressure = 0;
  final formKey = GlobalKey<FormState>();
  String medicineName = '';
  String allergy = '';
  String bloodPressure = 'Yok';
  String selectedDay = '';
  String selectedTime = '';

  final firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

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
    var height = MediaQuery.of(context).size.height;
    String topImage = "lib/assest/image/upside.png";
    String bottomImage = "lib/assest/image/downside.png";
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: height * 0.20,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(topImage),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20 ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleText(),
                        customSizeBox(),
                        useMedicineText(),
                        groupButtonMedicine(),
                        animatedContainerMedicine(),
                        customSizeBox(),
                        allergyText(),
                        groupButtonAllergy(),
                        animatedContainerAllergy(),
                        customSizeBox(),
                        bloodPressureText(),
                        groupButtonBloodPressure(),
                        customSizeBox(),
                        savedButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * 0.0, // bottom image için yükseklik belirtildi
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(bottomImage),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


SingleChildScrollView animatedContainerMedicine() {
  return SingleChildScrollView(
    child: ClipRect(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: valueMedicine == 1 ? 350 : 0,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "İlaç Adı :",
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
                child: TextFormField(
                  onSaved: (value) {
                    medicineName = value!;
                  },
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              customSizeBox(),
              Text(
                "Hangi günler kullanacaksın:",
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
                  value: selectedDay.isEmpty ? null : selectedDay,
                  onChanged: (newValue) {
                    setState(() {
                      selectedDay = newValue!;
                      selectedTime = ''; // Clear the time selection when day changes
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
                  child: Text(
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
    ),
  );
}

 
 
 
  AnimatedContainer animatedContainerAllergy() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: valueAllergy == 1 ? 150 : 0, // Yüksekliği daha küçük ayarlandı
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Alerjin var mı :",
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
              child: TextFormField(
                onSaved: (value) {
                  allergy = value!;
                },
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            customSizeBox(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  formKey.currentState!.save();
                  saveAllergy();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor(buttonColor),
                ),
                child: Text(
                  "Ekle",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row groupButtonMedicine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: RadioListTile<int>(
            title: Text("Evet"),
            value: 1,
            groupValue: valueMedicine,
            activeColor: HexColor('#3F51B5'),
            onChanged: (int? gelen) {
              setState(() {
                valueMedicine = gelen!;
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<int>(
            title: Text("Hayır"),
            value: 2,
            groupValue: valueMedicine,
            activeColor: HexColor('#3F51B5'),
            onChanged: (int? gelen) {
              setState(() {
                valueMedicine = gelen!;
              });
            },
          ),
        ),
      ],
    );
  }

  Row groupButtonBloodPressure() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: RadioListTile<int>(
            title: Text("Evet"),
            value: 1,
            groupValue: valueBloodPressure,
            activeColor: HexColor('#3F51B5'),
            onChanged: (int? gelen) {
              setState(() {
                valueBloodPressure = gelen!;
                bloodPressure = "Var";
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<int>(
            title: Text("Hayır"),
            value: 2,
            groupValue: valueBloodPressure,
            activeColor: HexColor('#3F51B5'),
            onChanged: (int? gelen) {
              setState(() {
                valueBloodPressure = gelen!;
                bloodPressure = "Yok";
              });
            },
          ),
        ),
      ],
    );
  }

  Row groupButtonAllergy() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: RadioListTile<int>(
            title: Text("Evet"),
            value: 1,
            groupValue: valueAllergy,
            activeColor: HexColor('#3F51B5'),
            onChanged: (int? gelen) {
              setState(() {
                valueAllergy = gelen!;
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<int>(
            title: Text("Hayır"),
            value: 2,
            groupValue: valueAllergy,
            activeColor: HexColor('#3F51B5'),
            onChanged: (int? gelen) {
              setState(() {
                valueAllergy = gelen!;
              });
            },
          ),
        ),
      ],
    );
  }

  Text titleText() {
    return Text(
      "HASTALIK BİLGİLERİ ",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20.0,
      ),
    );
  }

  Text useMedicineText() {
    return Text(
      "İlaç Kullanıyor musun ?",
      style: TextStyle(
        color: Colors.black,
        fontSize: 18.0,
      ),
    );
  }

  Text allergyText() {
    return Text(
      "Alerjin Var mı ?",
      style: TextStyle(
        color: Colors.black,
        fontSize: 18.0,
      ),
    );
  }

  Text bloodPressureText() {
    return Text(
      "Tansiyonun var mı ?",
      style: TextStyle(
        color: Colors.black,
        fontSize: 18.0,
      ),
    );
  }

  Center savedButton() {
    return Center(
      child: ElevatedButton(
        onPressed: saveBloodPressure,
            
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor(buttonColor),
        ),
        child: Text(
          "Kaydet",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  SizedBox customSizeBox() => SizedBox(height: 20);

  void saveMedicine() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      final medicineRef = databaseReference
          .child('users')
          .child(user.uid)
          .child('medicines')
          .child(medicineName);

      DateTime startDate = DateTime.now();
      DateTime endDate = startDate.add(Duration(days: 30));

      while (startDate.isBefore(endDate)) {
        if (startDate.weekday == getDayIndex(selectedDay)) {
          final dayRef = medicineRef.child('days').child(formatDate(startDate));
          await dayRef.child('times').set(selectedTime);
        }
        startDate = startDate.add(Duration(days: 1));
      }
    }
  }

  int getDayIndex(String day) {
    switch (day) {
      case 'Pazartesi':
        return DateTime.monday;
      case 'Salı':
        return DateTime.tuesday;
      case 'Çarşamba':
        return DateTime.wednesday;
      case 'Perşembe':
        return DateTime.thursday;
      case 'Cuma':
        return DateTime.friday;
      case 'Cumartesi':
        return DateTime.saturday;
      case 'Pazar':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  String formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  void saveAllergy() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      final allergyRef = databaseReference.child('users').child(user.uid).child('allergies').push();
      await allergyRef.set(allergy);
    }
  }

  void saveBloodPressure() async {
    User? user = firebaseAuth.currentUser;
   
    if (user != null) {
      await databaseReference.child('users').child(user.uid).update({
        'bloodPressure': bloodPressure,
      });

     
    }
      
    }
  }
