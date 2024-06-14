import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:remember_medicine/const/color.dart';

class InfoMedicine extends StatefulWidget {
  const InfoMedicine({Key? key}) : super(key: key);

  @override
  State<InfoMedicine> createState() => _InfoMedicineState();
}

class _InfoMedicineState extends State<InfoMedicine> {
  int valueMedicine = 0;
  int valueAllergy = 0;
  int valueBloodPresured = 0;
  final formKey = GlobalKey<FormState>();
  String medicineName = '';
  String allergy = '';
  String bloodPressure = 'Yok';
  List<String> selectedDays = [];
  List<String> selectedTimes = [];

  final firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    String topImage = "lib/assest/image/upside.png";
    String bottomImage = "lib/assest/image/downside.png";
    return Scaffold(
      body: Stack(
        children: [
          appBody(height, topImage, bottomImage),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * .0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(bottomImage),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  SingleChildScrollView appBody(double height, String topImage, String bottomImage) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: height * .25,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(topImage),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
            )
          ],
        ),
      ),
    );
  }

  AnimatedContainer animatedContainerMedicine() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: valueMedicine == 1 ? 380 : 0,
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
            child: TextFormField(
              onSaved: (value) {
                selectedDays = value!.split(',').map((e) => e.trim()).toList();
              },
              decoration: InputDecoration(border: InputBorder.none,
              hintText: "Kullandığınız günleri ',' ile ayırınız "),
            ),
          ),
          customSizeBox(),
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
            child: TextFormField(
              onSaved: (value) {
                selectedTimes = value!.split(',').map((e) => e.trim()).toList();
              },
              decoration: InputDecoration(border: InputBorder.none,
               hintText: "Kullandığınız saatleri ',' ile ayırınız "),
            ),
          ),
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
              child: Text(
                "Ekle",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AnimatedContainer animatedContainerAllergy() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: valueAllergy == 1 ? 380 : 0,
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
            groupValue: valueBloodPresured,
            activeColor: HexColor('#3F51B5'),
            onChanged: (int? gelen) {
              setState(() {
                valueBloodPresured = gelen!;
                bloodPressure = "Var";
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<int>(
            title: Text("Hayır"),
            value: 2,
            groupValue: valueBloodPresured,
            activeColor: HexColor('#3F51B5'),
            onChanged: (int? gelen) {
              setState(() {
                valueBloodPresured = gelen!;
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

      // Her bir gün için saatleri eklemek
      for (String day in selectedDays) {
        final dayRef = medicineRef.child('days').child(day);
        for (String time in selectedTimes) {
          await dayRef.child('times').push().set(time);
        }
      }
    }
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
