import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Bu satırı ekleyin
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:remember_medicine/Model/Model.dart';
import 'package:remember_medicine/Provider/Provier.dart';
import 'package:remember_medicine/Screen/Add_Alarm.dart';
import 'package:remember_medicine/const/color.dart';
import 'package:remember_medicine/page/auth/emergencyContacts.dart';
import 'package:remember_medicine/page/auth/home.dart';
import 'package:remember_medicine/page/auth/login.dart';
import 'package:remember_medicine/page/auth/mecidines_list.dart';
import 'package:remember_medicine/page/auth/profile.dart';
import 'package:remember_medicine/page/auth/reports.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class Notification_page extends StatefulWidget {
  const Notification_page({Key? key}) : super(key: key);

  @override
  State<Notification_page> createState() => _Notification_pageState();
}

class _Notification_pageState extends State<Notification_page> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    // Zaman dilimini ayarla
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul')); // Örneğin, Istanbul zaman dilimi

    // Bildirim izni iste (opsiyonel, uygulama ilk kez açılırken istenebilir)
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    // Provider'ı başlat
    context.read<alarmprovider>().Inituilize(context);

    // Her saniyede güncelle
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });

    // Verileri getir
    context.read<alarmprovider>().GetData();

    // Locale'i Türkçe olarak ayarla ve initializeDateFormatting fonksiyonunu çağır
    Intl.defaultLocale = 'tr'; // Bu satırı ekledik
    initializeDateFormatting('tr', null).then((_) { // Bu satırı ekledik
      setState(() {}); // UI'ı güncelle
    });
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Login_page()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alarm Oluştur',
          style: TextStyle(color: Colors.black),
        ),
      ),
      drawer: menuDrawer(context),
      body: ListView(
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            height: MediaQuery.of(context).size.height * 0.1,
            child: Center(
              child: Text(
                // Tarih ve saat formatını Türkçe olarak ayarladık
                DateFormat.yMMMMEEEEd('tr').add_jms().format(DateTime.now()), // Bu satırı değiştirdik
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),
            ),
          ),
          Consumer<alarmprovider>(builder: (context, alarm, child) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: ListView.builder(
                itemCount: alarm.modelist.length,
                itemBuilder: (BuildContext, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      alarm.modelist[index].dateTime!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        "|" +
                                            alarm.modelist[index].label
                                                .toString(),
                                      ),
                                    ),
                                  ],
                                ),
                                CupertinoSwitch(
                                  value: (alarm.modelist[index].milliseconds! <
                                          DateTime.now().microsecondsSinceEpoch)
                                      ? false
                                      : alarm.modelist[index].check,
                                  onChanged: (v) {
                                    alarm.EditSwitch(index, v);
                                    alarm.CancelNotification(
                                        alarm.modelist[index].id!);
                                  },
                                  activeColor: HexColor(buttonColor),
                                ),
                              ],
                            ),
                            Text(alarm.modelist[index].when!),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              color: Colors.deepPurpleAccent,
            ),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  // Yeni alarm eklemek için AddAlarm sayfasına yönlendirme
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddAlarm()),
                  );

                  // AddAlarm sayfasından dönen sonucu işle
                  if (result != null && result is Model) {
                    // Örneğin, alarm eklendikten sonra verileri güncelleme
                    context.read<alarmprovider>().GetData();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Drawer menuDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Center(
            child: Text(
              "Menü",
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
              ),
            ),
          ),
          customSizeBox(),
          ListTile(
            leading: Icon(
              Icons.home,
              size: 22,
              color: Colors.black45,
            ),
            title: const Text(
              "Anasayfa",
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          customSizeBox(),
          ListTile(
            leading: Icon(
              Icons.alarm,
              size: 22,
              color: Colors.black45,
            ),
            title: const Text(
              "Alarm",
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Notification_page()),
              );
            },
          ),
          customSizeBox(),
          ListTile(
            leading: Icon(
              Icons.library_books,
              size: 22,
              color: Colors.black45,
            ),
            title: const Text(
              "İlaç Listesi",
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MedicinesListPage()),
              );
            },
          ),
          customSizeBox(),
          ListTile(
            leading: Icon(
              Icons.calendar_month,
              size: 22,
              color: Colors.black45,
            ),
            title: const Text(
              "Takvim",
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ReportsPage()),
              );
            },
          ),
          customSizeBox(),
          ListTile(
            leading: Icon(
              Icons.person_add_alt_1_sharp,
              size: 22,
              color: Colors.black45,
            ),
            title: const Text(
              "Acil Durum",
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EmergencyPage()),
              );
            },
          ),
          customSizeBox(),
          ListTile(
            leading: Icon(
              Icons.person,
              size: 22,
              color: Colors.black45,
            ),
            title: const Text(
              "Profil",
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          customSizeBox(),
          ListTile(
            leading: Icon(
              Icons.logout,
              size: 22,
              color: Colors.black45,
            ),
            title: const Text(
              "Çıkış Yap",
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 53, 49, 49),
              ),
            ),
            onTap: () {
              signOut(context);
            },
          ),
          customSizeBox(),
        ],
      ),
    );
  }

  SizedBox customSizeBox() => SizedBox(height: 12);
}
