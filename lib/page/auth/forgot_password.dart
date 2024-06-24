import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:remember_medicine/page/auth/login.dart'; // Login_page import edin

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth mAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Şifre yenileme gönderilecek e-posta giriniz",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Form(
              key: formKey,
              child: Column(
                children: [
                  emailTextField(),
                  SizedBox(height: 20),
                  sendEmailButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton sendEmailButton() {
    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          await sendPasswordResetLink(emailController.text);
        }
      },
      child: Text("Gönder"),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  TextFormField emailTextField() {
    return TextFormField(
      controller: emailController,
      validator: (value) {
        if (value!.isEmpty) {
          return "Bir e-posta adresi giriniz";
        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return "Geçerli bir e-posta adresi giriniz";
        } else {
          return null;
        }
      },
      decoration: costumInputDecoration("E-Mail"),
      style: TextStyle(color: Colors.black),
    );
  }

  InputDecoration costumInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: HexColor(backgroundColor)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: HexColor(buttonColor)),
      ),
    );
  }

  Future<void> sendPasswordResetLink(String email) async {
    try {
      await mAuth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Şifre sıfırlama e-postası gönderildi")),
      );

      // Başarılı olursa giriş sayfasına yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login_page()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bir hata oluştu")),
      );
      print(e.toString());
    }
  }
}
