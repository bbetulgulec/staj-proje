import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:remember_medicine/Model/Model.dart';
import 'package:remember_medicine/Provider/Provier.dart';
import 'package:remember_medicine/Screen/Add_Alarm.dart';
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
    tz.setLocalLocation(
        tz.getLocation('Europe/Istanbul')); // Örneğin, Istanbul zaman dilimi

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEFF5),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.menu,
              color: Colors.white,
            ),
          )
        ],
        title: const Text(
          'Alarm Saati',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.circular(10)),
            height: MediaQuery.of(context).size.height * 0.1,
            child: Center(
              child: Text(
                DateFormat.yMEd().add_jms().format(DateTime.now()),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
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
                                        "|" + alarm.modelist[index].label.toString(),
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
                                    alarm.CancelNotification(alarm.modelist[index].id!);
                                  },
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
}
