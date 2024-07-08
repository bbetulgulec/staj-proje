import 'dart:math';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/Provider/Provier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:remember_medicine/const/color.dart';

class AddAlarm extends StatefulWidget {
  const AddAlarm({super.key});

  @override
  State<AddAlarm> createState() => _AddAlaramState();
}

class _AddAlaramState extends State<AddAlarm> {
  late TextEditingController controller;

  String? dateTime;
  bool repeat = false;

  DateTime? notificationtime;

  String? name = "";
  int ? Milliseconds;

   static const platform = MethodChannel('com.example.my_wear_os_app/data');

  @override
  void initState() {
    controller = TextEditingController();
    context.read<alarmprovider>().GetData();
    super.initState();
  }

    Future<void> _sendDataToWearOS(String data) async {
    try {
      final String result = await platform.invokeMethod('sendDataToWearOS', {'data': data});
      print(result);
    } on PlatformException catch (e) {
      print("Failed to send data: '${e.message}'.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor(backgroundColor),
        automaticallyImplyLeading: true,
        title: const Text(
          'Alarm Ekle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        
      ),
      
  
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          dateCalender(context),
          customSizeBox(),
          madicaneName(context),
          customSizeBox(),
          swicthRepeatDaily(),
          customSizeBox(),
          setAlarms(context),
        ],
      ),
    );
  }

  Container dateCalender(BuildContext context) {
    return Container(
          height: MediaQuery.of(context).size.height * 0.3,
          width: MediaQuery.of(context).size.width,
          child: Center(
              child: CupertinoDatePicker(
            showDayOfWeek: true,
            minimumDate: DateTime.now(),
            dateOrder: DatePickerDateOrder.dmy,
            onDateTimeChanged: (va) {
              dateTime = DateFormat().add_jms().format(va);

              Milliseconds = va.microsecondsSinceEpoch;

              notificationtime = va;

              print(dateTime);
            },
          )),
        );
  }

  Padding madicaneName(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(

              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoTextField(
                  placeholder: "İlaç Adı",
                  controller: controller,
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              )),
        );
  }

  Row swicthRepeatDaily() {
    return Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Hergün tekrarlansın mı ? "),
            ),
            CupertinoSwitch(
              value: repeat,
              onChanged: (bool value) {
                repeat = value;

                if (repeat == false) {
                  name = "none";
                } else {
                  name = "Everyday";
                }

                setState(() {});
              },
            ),
          ],
        );
  }

  ElevatedButton setAlarms(BuildContext context) {
    return ElevatedButton(
      
            onPressed: () {
              Random random = new Random();
              int randomNumber = random.nextInt(100);

              context.read<alarmprovider>().SetAlaram(
                  controller.text, dateTime!, true, name!, randomNumber,Milliseconds!);
              context.read<alarmprovider>().SetData();

              context
                  .read<alarmprovider>()
                  .SecduleNotification(notificationtime!, randomNumber);
                  // Veri gönderme işlemi
        _sendDataToWearOS(controller.text + ' ' + dateTime!);

              Navigator.pop(context);
            },
            child: Text("alarmı kur ", style: TextStyle(
              
            color:Colors.black54,
            fontSize: 20,
            fontStyle: FontStyle.italic,
            ),)
            );

  }
  
  SizedBox customSizeBox() => SizedBox(height: 12);
}
