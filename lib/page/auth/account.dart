import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:remember_medicine/page/auth/login.dart';
import 'package:firebase_database/firebase_database.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late String email, password, name, surname, gender;
  late String age, number, height, weight;
  final formKey = GlobalKey<FormState>();
  final firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    String topImage = "lib/assest/image/upside.png";
    String bottomImage = "lib/assest/image/downside.png";

    return Scaffold(
      body: Stack(
        children: [
          appBody(height, width, topImage, bottomImage),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * 0.0,
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

  SingleChildScrollView appBody(double height, double width, String topImage, String bottomImage) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: height * 0.17,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(topImage),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customSizeBox(),
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
                    customSizeBox(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: backToLoginButton()),
                          SizedBox(width: 10),
                          Flexible(child: createAccountButton()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget titleText() {
    return Center(
      child: Text(
        "HESAP OLUŞTUR",
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
          color: HexColor(primaryColor),
        ),
      ),
    );
  }

  TextFormField nametextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Adınızı giriniz";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        name = value!.toUpperCase();
      },
      style: TextStyle(color: Colors.black),
      decoration: customInputDecoration("Ad"),
    );
  }

  TextFormField surnametextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Soyisminizi giriniz";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        surname = value!.toUpperCase();
      },
      style: TextStyle(color: Colors.black),
      decoration: customInputDecoration("Soyad"),
    );
  }

  TextFormField agetextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Yaşınızı giriniz";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        age = value!;
      },
      style: TextStyle(color: Colors.black),
      decoration: customInputDecoration("Yaş"),
    );
  }

  TextFormField numbertextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Telefonunuzu giriniz";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        number = value!;
      },
      style: TextStyle(color: Colors.black),
      decoration: customInputDecoration("Telefon"),
    );
  }

  TextFormField heighttextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Boyunuzu giriniz";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        height = value!;
      },
      style: TextStyle(color: Colors.black),
      decoration: customInputDecoration("Boy"),
    );
  }

  TextFormField weighttextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Kilonuzu giriniz";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        weight = value!;
      },
      style: TextStyle(color: Colors.black),
      decoration: customInputDecoration("Kilo"),
    );
  }

  TextFormField gendertextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Cinsiyetinizi giriniz";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        gender = value!.toUpperCase();
      },
      style: TextStyle(color: Colors.black),
      decoration: customInputDecoration("Cinsiyet"),
    );
  }

  TextFormField mailtextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Bir e-posta adresi giriniz";
        } else if (!EmailValidator.validate(value)) {
          return "Geçerli bir e-posta adresi giriniz";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        email = value!;
      },
      style: TextStyle(color: Colors.black),
      decoration: customInputDecoration("E-Mail"),
    );
  }

  TextFormField passwordtextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Şifrenizi giriniz";
        } else if (value.length < 6) {
          return "Şifreniz en az 6 karakter olmalıdır";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        password = value!;
      },
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: "Şifre",
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: HexColor(textfieldColor)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: HexColor(textfieldColor)),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }

  Center createAccountButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: saved,
        label: Text(
          "Kayıt Et",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.0,
          ),
        ),
        icon: Icon(Icons.check, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor(buttonColor),
          padding: EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Future<void> saved() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User user = userCredential.user!;
        print('Veri başarıyla authenticationa kayıt oldu');

        await user.sendEmailVerification();
        print('Doğrulama e-postası gönderildi');

        await databaseReference.child('users').child(user.uid).set({
          'name': name,
          'surname': surname,
          'email': email,
          'number': number,
          'age': age,
          'gender': gender,
          'weight': weight,
          'height': height,
          'password': password 
        });

        formKey.currentState!.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Kayıt Oluşturuldu. Lütfen e-posta adresinizi doğrulayın.",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login_page()),
        );
      } catch (e) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Kayıt Oluşturulamadı: ${e.toString()}",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        );
      }
    }
  }

  Center backToLoginButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login_page()),
          );
        },
        label: Text(
          "Giriş sayfasına  geri dön",
          style: TextStyle(
            color: HexColor(ButtonText),
            fontSize: 10.0,
          ),
        ),
        icon: Icon(Icons.arrow_back_ios_new, color: Colors.black45),
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor(buttonColor2),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget customSizeBox() => SizedBox(height: 40.0);

  InputDecoration customInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey,
        fontSize: 20,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: HexColor(textfieldColor)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: HexColor(textfieldColor)),
      ),
    );
  }
}
