import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:remember_medicine/page/auth/login.dart';
import 'package:remember_medicine/page/auth/home.dart'; // Import HomePage
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => SplashScreenPageState();
}

class SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds to simulate a splash screen
    Future.delayed(Duration(seconds: 3), () async {
      // Check if user is already signed in
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // User is signed in, navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // User is not signed in, navigate to Login_page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login_page()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor(backgroundColor),
      body: Center(
        child: Image.asset(
          "lib/assest/image/splash_icon.png",
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}
