import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/page/auth/account.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:email_validator/email_validator.dart';
import 'package:remember_medicine/page/auth/forgot_password.dart';
import 'package:remember_medicine/page/auth/home.dart';

class Login_page extends StatefulWidget {
  const Login_page({Key? key}) : super(key: key);

  @override
  State<Login_page> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login_page> {
  late String email, password;
  final formKey = GlobalKey<FormState>();
  bool _obscureText = true;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    bool isKeyboardOpen = keyboardHeight > 0;
    String topImage = "lib/assest/image/upside.png";
    String bottomImage = "lib/assest/image/downside.png";
    return Scaffold(
        body: Stack(
      children: [
        appBody(height, topImage, bottomImage),
        if(!isKeyboardOpen)
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: height * .19,
            decoration: BoxDecoration(
                image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(bottomImage),
            )),
          ),
        )
      ],

    ));
  }

  SingleChildScrollView appBody(double height, String topImage, String bottomImage) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: height * .19,
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(topImage),
              )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customSizeBox(),
                    titleText(),
                    customSizeBox(),
                    mailtextfield(),
                    customSizeBox(),
                    passwordtextfield(),
                    forgotPasswordButton(),
                    customSizeBox(),
                    signInButton(),
                    customSizeBox(),
                    createAccountButton(),
                    customSizeBox(),
                  ],
                ),
              ),
            ),

          ],

        ),
      ),
    );
  }

  Widget titleText() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Text(
        "GİRİŞ YAP ",
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: HexColor(primaryColor),
        ),
      ),
    );
  }

  Widget mailtextfield() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0,left: 20.0),
      child: TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return "Bir e-posta adresi giriniz ";
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
        decoration: InputDecoration(
        prefixIcon: Icon(Icons.person),
        hintText: "E-Mail",
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 25,
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: HexColor(textfieldColor),
        )),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: HexColor(textfieldColor))),
        )
      ),
    );
  }


  Widget passwordtextfield() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20.0),
      child: TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return "Şifrenizi giriniz ";
          } else if (value.length < 6) {
            return "Şifreniz en az 6 karakter olmalıdır";
          } else {
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
            fontSize: 25,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: HexColor(textfieldColor)), // replace with your backgroundColor
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: HexColor(textfieldColor)), // replace with your buttonColor
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
      ),
    );
  }

  Align forgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: TextButton(
                onPressed: () {
          Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => ForgotPassword()));
                },
                child: Text(
          "Şifremi Unuttum ?",
          style: TextStyle(
            color:Colors.black54,
            fontSize: 20,
            fontStyle: FontStyle.italic,
          ),
                ),
              ),
        ));
  }

  Center createAccountButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AccountPage(),
            ),
          );
        },
        label: Text(
          "Hesap Oluştur",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
          ),
        ),
        icon: Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor(buttonColor),
          padding: EdgeInsets.symmetric(horizontal: 25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Center signInButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            try {
              if (kIsWeb) {
                await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
              }
              UserCredential userCredential = await FirebaseAuth.instance
                  .signInWithEmailAndPassword(email: email, password: password);

              User? user = userCredential.user;

              if (user != null && !user.emailVerified) {
                await user.sendEmailVerification();
                await FirebaseAuth.instance.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('E-posta adresiniz doğrulanmamış. Lütfen e-postanızı kontrol edin.'),
                  ),
                );
              } else if (user != null && user.emailVerified) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Başarıyla giriş yaptınız")),
                );
              }
            } on FirebaseAuthException catch (e) {
              String errorMessage;
              if (e.code == 'user-not-found') {
                errorMessage = "Kullanıcı bulunamadı. Lütfen e-posta adresinizi kontrol edin.";
              } else if (e.code == 'wrong-password') {
                errorMessage = "Yanlış şifre. Lütfen şifrenizi kontrol edin.";
              } else if (e.code == 'invalid-credential') {
                errorMessage = "Geçersiz kimlik bilgisi. Lütfen tekrar deneyin.";
              } else {
                errorMessage = "Giriş başarısız! Lütfen e-posta ve şifrenizi kontrol edin.";
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage)),
              );
              print(e.message);
            }
          }
        },
        label: Text(
          "Giriş Yap",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
          ),
        ),
        icon: Icon(Icons.check, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor(buttonColor),
          padding: EdgeInsets.symmetric(horizontal: 25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget customSizeBox() => SizedBox(
        height: 30.0,
      );


  InputDecoration costumInputDecaretion(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey,
        fontSize: 30,
      ),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
        color: HexColor(backgroundColor),
      )),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: HexColor(buttonColor))),
    );
  }
}