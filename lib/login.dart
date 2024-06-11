import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/account.dart';
import 'package:remember_medicine/const/color.dart';
import "package:email_validator/email_validator.dart"; // Bu kütüphaneyi ekledim

class Login_page extends StatefulWidget {
  const Login_page({Key? key}) : super(key: key);

  @override
  State<Login_page> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login_page> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _emailErrorMessage = '';
  String _passwordErrorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor(backgroundColor),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [



            //GİRİŞ YAP YAZISI
            Text(
              'Giriş Yap',
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: HexColor(primaryColor),
              ),
            ),
            SizedBox(height: 40.0),

            //E-POSTA GİRİŞİ

            Container(
              padding: EdgeInsets.symmetric(horizontal: 70.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-Posta',
                  labelStyle: TextStyle(color: HexColor(secondryColor)),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: HexColor(secondryColor)),
                  ),
                  errorText:
                      _emailErrorMessage.isNotEmpty ? _emailErrorMessage : null,
                ),
              ),
            ),
            SizedBox(height: 20.0),

            //ŞİFRE GİRİŞİ

            Container(
              padding: EdgeInsets.symmetric(horizontal: 70.0),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  labelStyle: TextStyle(color: HexColor(secondryColor)),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: HexColor(secondryColor)),
                  ),
                  errorText: _passwordErrorMessage.isNotEmpty
                      ? _passwordErrorMessage
                      : null,
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 20.0),

            //GİRİŞ YAP BUTTON

            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  bool validEmail = EmailValidator.validate(
                      _emailController.text); // Eposta doğrulaması yapılıyor

                  _emailErrorMessage = _emailController.text.isEmpty
                      ? 'Lütfen eposta giriniz.'
                      : validEmail
                          ? ''
                          : 'Lütfen geçerli bir e-posta girin.'; // Eğer geçerli bir eposta değilse hata mesajı atanıyor
                  _passwordErrorMessage = _passwordController.text.isEmpty
                      ? 'Lütfen şifre giriniz.'
                      : '';

                  if (_emailErrorMessage.isEmpty &&
                      _passwordErrorMessage.isEmpty) {
                    // Burada giriş işlemleri yapılabilir
                  }
                });
              },
              label: Text(
                "Giriş Yap",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              icon: Icon(Icons.check, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor(buttonColor),
                fixedSize: Size(180, 60),
              ),
            ),
            SizedBox(height: 20.0),

            //HESAP OLUŞTUR BUTTON

            ElevatedButton.icon(
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
                  fontSize: 20.0,
                ),
              ),
              icon: Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor(buttonColor),
                padding: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
            SizedBox(height: 20.0),

            //ŞİFREMİ UNUTTUM BUTTON

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor(buttonColor),
                fixedSize: Size(180, 60),
              ),
              child: Text(
                "Şifremi Unuttum",
                style: TextStyle(
                  fontStyle: FontStyle.italic, // Yazı italik olacak
                  decoration: TextDecoration
                      .underline, // Yazının altına çizgi eklenecek
                  color: Colors.white, // Yazı mavi olacak
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
