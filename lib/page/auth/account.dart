import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:remember_medicine/page/auth/info_medicine.dart';
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
  bool _obscureText = true; // Şifre gizleme durumu

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
                    customSizeBox(),
                    createAccountButton(),
                    customSizeBox(),
                    backToLoginButton(),
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
        color: HexColor('#3F51B5'), // replace with your primaryColor
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
      decoration: customInputDecoration("Ad "),
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
      decoration: customInputDecoration("Soyad "),
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
      decoration: customInputDecoration("Yaş "),
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
      decoration: customInputDecoration("Telefon "),
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
      decoration: customInputDecoration("Boy "),
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
      decoration: customInputDecoration("Kilo "),
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
      decoration: customInputDecoration("Cinsiyet "),
    );
  }

  TextFormField mailtextfield() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Bir e-posta adresi giriniz ";
        } else if (!EmailValidator.validate(value!)) {
          return "Geçerli bir e-posta adresi giriniz";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        email = value!;
      },
      style: TextStyle(color: Colors.black),
      decoration: customInputDecoration("E-Mail "),
    );
  }

 TextFormField passwordtextfield() {
  return TextFormField(
    validator: (value) {
      if (value!.isEmpty) {
        return "Şifrenizi giriniz ";
      } else if (value.length < 6) {
        return "Şifreniz en az 6 karakter olmalıdır";
      } 
      else {
        return null;
      }
    },
    onSaved: (value) {
      password = value!;
    },
    obscureText: _obscureText, // Şifre gizleme durumu
    decoration: InputDecoration(
      hintText: "Şifre",
      hintStyle: TextStyle(
        color: Colors.grey,
        fontSize: 20,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: HexColor(backgroundColor)), // replace with your backgroundColor
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color:HexColor(backgroundColor)), // replace with your buttonColor
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
            fontSize: 23.0,
          ),
        ),
        icon: Icon(Icons.check, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor(buttonColor), // replace with your buttonColor
          padding: EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Future<void> saved() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        // Kullanıcıyı Firebase Authentication ile oluştur
        var userResult = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('Veri başarıyla authenticationa kayıt oldu');

        // Kullanıcı bilgilerini Firebase Realtime Database'e kaydet
        await databaseReference.child('users').child(userResult.user!.uid).set({
          'name': name,
          'surname': surname,
          'email': email,
          'number': number,
          'age': age,
          'gender': gender,
          'weight': weight,
          'height': height,
          'pasword':password
          // Diğer kullanıcı bilgileri
        });

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InfoMedicine()),
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
          "Giriş sayfasına geri dön",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.0,
          ),
        ),
        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor(buttonColor), // replace with your buttonColor
          padding: EdgeInsets.symmetric(horizontal: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget customSizeBox() => SizedBox(height: 20.0,);

  InputDecoration customInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey,
        fontSize: 20,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: HexColor(backgroundColor)), // replace with your backgroundColor
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: HexColor(buttonColor)), // replace with your buttonColor
      ),
    );
  }
}
