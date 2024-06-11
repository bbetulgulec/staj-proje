import 'package:flutter/material.dart';
import 'package:remember_medicine/splash.dart';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreenPage(),
    );
  }
}

