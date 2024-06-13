import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/page/auth/account.dart';
import 'package:remember_medicine/const/color.dart';
import "package:email_validator/email_validator.dart";
import 'package:remember_medicine/page/auth/login.dart';
import 'package:firebase_database/firebase_database.dart';

class account_page extends StatefulWidget {

  const account_page({Key? key}) : super(key: key);

  @override
  State<account_page> createState() => _account_page();
}

class _account_page extends State<account_page> {
  
  late String email, password, name, surname, gender;
  late String age, number, height, weight;
  final formKey = GlobalKey<FormState>();
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
              height: height * .15,
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
                    nametextfield(),
                    customSizeBox(),
                    surnametextfield(),
                    customSizeBox(),
                    mailtextfield(),
                    customSizeBox(),
                    numbertextfield(),
                    customSizeBox(),
                    agetextfield(),
                    customSizeBox(),
                    gendertextfield(),
                    customSizeBox(),
                    weighttextfield(),
                    customSizeBox(),
                    heighttextfield(),
                    customSizeBox(),
                    passwordtextfield(),
                    createAccountButton(),
                    BacktoLoginButton(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Text titleText() {
    return Text(
      "HESAP OLUŞTUR ",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: HexColor(primaryColor),
      ),
    );
  }

  TextFormField nametextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Adınızı giriniz ";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        name = value!;
      },
      style: TextStyle(color: Colors.black),
      decoration: costumInputDecaretion("Ad "),
    );
  }

  TextFormField surnametextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Soyisminizi giriniz ";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        surname = value!;
      },
      style: TextStyle(color: Colors.black),
      decoration: costumInputDecaretion("Soyad "),
    );
  }

  TextFormField agetextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Yaşınızı giriniz ";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        age = value!;
      },
      style: TextStyle(color: Colors.black),
      decoration: costumInputDecaretion("Yaş "),
    );
  }

  TextFormField numbertextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Telefonunuzu giriniz ";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        number = value!;
      },
      style: TextStyle(color: Colors.black),
      decoration: costumInputDecaretion("Telefon "),
    );
  }

  TextFormField heighttextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Boyunuzu giriniz ";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        height = value!;
      },
      style: TextStyle(color: Colors.black),
      decoration: costumInputDecaretion("Boy "),
    );
  }

  TextFormField weighttextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Kilonuzu giriniz ";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        weight = value!;
      },
      style: TextStyle(color: Colors.black),
      decoration: costumInputDecaretion("Kilo "),
    );
  }

  TextFormField gendertextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Cinsiyetinizi giriniz ";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        gender = value!;
      },
      style: TextStyle(color: Colors.black),
      decoration: costumInputDecaretion("Cinsiyet "),
    );
  }

  TextFormField mailtextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Bir e-posta adresi giriniz ";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        email = value!;
      },
      style: TextStyle(color: Colors.black),
      decoration: costumInputDecaretion("E-Mail "),
    );
  }

  TextFormField passwordtextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Şifrenizi giriniz ";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        password = value!;
      },
      decoration: costumInputDecaretion("şifre "),
    );
  }

  Center createAccountButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: createAccount,
        label: Text(
          "Hesap Oluştur",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
          ),
        ),
        icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor(buttonColor),
          padding: EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  void createAccount() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        // Kullanıcıyı Firebase Authentication ile oluştur
        var userResult = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
         print('Veri başarıyla authanticationa kayıt oldu ');

        // Firebase Realtime Database'e kullanıcı bilgilerini kaydetme
        await databaseReference.child('users').child(userResult.user!.uid).set({
          'name': name,
          'surname': surname,
          'email': email,
          'number': number,
          'age': age,
          'gender': gender,
          'weight': weight,
          'height': height,
          // Diğer kullanıcı bilgileri
        });
         print('Veri başarıyla yazıldı');

        formKey.currentState!.reset();
        ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
            content: Text(
              "Kayıt Oluşturuldu",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        );

        // Kayıt işlemi tamamlandıktan sonra login sayfasına yönlendirme
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Login_page()),
        );
      } catch (e) {
        print(e.toString());
      }
    }
  }

  Center BacktoLoginButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Login_page()),
          );
        },
        label: Text(
          "Giriş sayfasına geri dön",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor(buttonColor),
          padding: EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget customSizeBox() => SizedBox(
        height: 20.0,
      );

  InputDecoration costumInputDecaretion(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey,
        fontSize: 20,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: HexColor(backgroundColor)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: HexColor(buttonColor)),
      ),
    );
  }
}

