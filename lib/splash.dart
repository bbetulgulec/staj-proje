import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:remember_medicine/login.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => SplashScreenPageState();
}

class SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3)).then(
      (onValue) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Login_page(),
        ),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor(backgroundColor),
      body: Center(
        child: Image.asset(
          "lib/assest/image/splash_icon.png",
          width: 100, // İkonun genişliği
          height: 100, // İkonun yüksekliği
        ),
        
      ),
    );
  }
}
