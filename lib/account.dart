import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/const/color.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _nameErrorMessage = '';
  String _surnameErrorMessage = '';
  String _emailErrorMessage = '';
  String _phoneErrorMessage = '';
  String _heightErrorMessage = '';
  String _weightErrorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor(backgroundColor),
      body: Padding(
        padding: const EdgeInsets.only(top: 80.0,right: 20.0,left: 20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

                //HESAP BİLGİLERİ

              Text(
                'Hesap Bilgileri',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: HexColor(primaryColor),
                ),
              ),
              SizedBox(height: 50.0),

              //AD GİRİNİZ 
              Container(
                padding: EdgeInsets.symmetric(horizontal: 70.0),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Ad',
                    labelStyle: TextStyle(color: HexColor(secondryColor)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: HexColor(secondryColor)),
                    ),
                    errorText:
                    _nameErrorMessage.isNotEmpty ? _nameErrorMessage : null,
                  ),
                ),
              ),
              SizedBox(height: 30.0),

              //SOYAD GİRİNİZ
              Container(
                padding: EdgeInsets.symmetric(horizontal: 70.0),
                child: TextField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    labelText: 'Soyad',
                    labelStyle: TextStyle(color: HexColor(secondryColor)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: HexColor(secondryColor)),
                    ),
                    errorText:
                    _surnameErrorMessage.isNotEmpty ? _surnameErrorMessage : null,
                  ),
                ),
              ),
              SizedBox(height: 30.0),

              //E-POSTA GİRİNİZ

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
              SizedBox(height: 30.0),

              //TELEFON GİRİNİZ 

              Container(
                padding: EdgeInsets.symmetric(horizontal: 70.0),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    labelText: 'Telefon',
                    labelStyle: TextStyle(color: HexColor(secondryColor)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: HexColor(secondryColor)),
                    ),
                    errorText:
                    _phoneErrorMessage.isNotEmpty ? _phoneErrorMessage : null,
                  ),
                ),
              ),
              SizedBox(height: 30.0),

              //BOY GİRİNİZ 

              Container(
                padding: EdgeInsets.symmetric(horizontal: 70.0),
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    labelText: 'Boy',
                    labelStyle: TextStyle(color: HexColor(secondryColor)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: HexColor(secondryColor)),
                    ),
                    errorText:
                    _heightErrorMessage.isNotEmpty ? _heightErrorMessage : null,
                  ),
                ),
              ),
              SizedBox(height: 30.0),

              //KİLO GİRİNİZ 

              Container(
                padding: EdgeInsets.symmetric(horizontal: 70.0),
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    labelText: 'Kilo',
                    labelStyle: TextStyle(color: HexColor(secondryColor)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: HexColor(secondryColor)),
                    ),
                    errorText:
                    _weightErrorMessage.isNotEmpty ? _weightErrorMessage : null,
                  ),
                ),
              ),
              SizedBox(height: 30.0),

              //BİLGİLERİ KAYDET

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _nameErrorMessage = _nameController.text.isEmpty
                        ? 'Lütfen adınızı giriniz.'
                        : '';
                    _surnameErrorMessage = _surnameController.text.isEmpty
                        ? 'Lütfen soyadınızı giriniz.'
                        : '';
                    _emailErrorMessage = _emailController.text.isEmpty
                        ? 'Lütfen e-posta adresinizi giriniz.'
                        : '';
                    _phoneErrorMessage = _phoneController.text.isEmpty
                        ? 'Lütfen telefon numaranızı giriniz.'
                        : '';
                    _heightErrorMessage = _heightController.text.isEmpty
                        ? 'Lütfen boyunuzu giriniz.'
                        : '';
                    _weightErrorMessage = _weightController.text.isEmpty
                        ? 'Lütfen kilonuzu giriniz.'
                        : '';
                    
                    if (_nameErrorMessage.isEmpty &&
                        _surnameErrorMessage.isEmpty &&
                        _emailErrorMessage.isEmpty &&
                        _phoneErrorMessage.isEmpty &&
                        _heightErrorMessage.isEmpty &&
                        _weightErrorMessage.isEmpty) {
                      // Bilgiler kaydedilebilir
                    }
                  });
                },
                child: Text(
                  'Bilgileri Kaydet',
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  
                ),
                ),
                style: ElevatedButton.styleFrom(
                backgroundColor:HexColor(buttonColor), // Arka plan rengini mavi yapar
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
