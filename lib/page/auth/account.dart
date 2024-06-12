import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/page/auth/account.dart';
import 'package:remember_medicine/const/color.dart';
import "package:email_validator/email_validator.dart";
import 'package:remember_medicine/page/auth/login.dart';

class account_page extends StatefulWidget {
  const account_page({Key? key}) : super(key: key);

  @override
  State<account_page> createState() => _account_page();
}

class _account_page extends State<account_page> {
  
  late String email,password;
  final formKey=GlobalKey<FormState>();
  final firebaseAuth=FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    var height=MediaQuery.of(context).size.height;
    String topImage="lib/assest/image/upside.png";
    String bottomImage="lib/assest/image/downside.png";
    return Scaffold(
      body:Stack(
        children: [
          appBody(height, topImage, bottomImage),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height*.25,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit:BoxFit.cover,
                  image: AssetImage(bottomImage),)
              ),
            ),
          )
        ],
      )
    );
  
  }

  SingleChildScrollView appBody(double height,String topImage,String BottomImage) {
    return SingleChildScrollView(
      child: Center(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
             height: height*.25,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit:BoxFit.cover,
                  image: AssetImage(topImage),
                )
              ),
          
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key:formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleText(),
                    customSizeBox(),
                    mailtextfield(),
                    customSizeBox(),
                    passwordtextfield(),
                    customSizeBox(),
                    createAccountButton(),
                    customSizeBox(),
                    BacktoLoginButton()
                
                    
                  ],
                ),
              ),
            )
    
        ],) 
        ,),
    );
  }

  Text titleText(){
    return Text(
      "HESAP OLUŞTUR ",
      style:TextStyle(
          fontSize: 50,
          fontWeight: FontWeight.bold,
          color: HexColor(primaryColor),
          ),
          );
  }

  TextFormField mailtextfield(){
    return TextFormField(
      validator: (value){
        if(value!.isEmpty){
          return "Bir e-posta adresi giriniz ";
        }
        else{

        }
      },
      onSaved: (value){
          email=value!;
      },
      style: TextStyle(color: Colors.black),
        decoration: costumInputDecaretion("E-Mail "),

    );

  }



   TextFormField passwordtextfield(){
    return TextFormField(
      
      validator: (value){
        if(value!.isEmpty){
          return "Şifrenizi giriniz ";
        }
        else{

        }
      },
      onSaved: (value){
          password=value!;
      },
        decoration: costumInputDecaretion("şifre "),

    );

  }

   

    Center createAccountButton(){
      return Center(
        child: ElevatedButton.icon(
         onPressed: creatAccount,
         label: Text("Hesap Oluştur",
         style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
         ),
          ),
            icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                 style: ElevatedButton.styleFrom(
                 backgroundColor: HexColor(buttonColor),
                 padding: EdgeInsets.symmetric(horizontal: 20),
                 shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(10)),
           ),
           ),
           );
    }

    void creatAccount() async {
        if(formKey.currentState!.validate()){
              formKey.currentState!.save();
              try{
                var userResult =await firebaseAuth.createUserWithEmailAndPassword(
                email: email, password: password);
                formKey.currentState!.reset();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kayıt Oluşturuldu", style: TextStyle(
                  fontSize: 20,
                ),),
                ),
                );
                Navigator.push(
               context,
                MaterialPageRoute(builder: (context)=>const Login_page(),
          ),
          );
              }
              catch(e){
                  print(e.toString());
              }
        }
       }

     Center BacktoLoginButton(){
      return Center(
        child: ElevatedButton.icon(
         onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context)=>const Login_page(),
            ),
            );
         },
         label: Text("Giriş sayfasına geri dön",
         style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
         ),
          ),
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                 style: ElevatedButton.styleFrom(
                 backgroundColor: HexColor(buttonColor),
                 padding: EdgeInsets.symmetric(horizontal: 20),
                 shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(10)),
           ),
           ),
           );
    }





  Widget customSizeBox()=>SizedBox(
    height: 20.0,
  );
  InputDecoration costumInputDecaretion(String hintText) {
    return InputDecoration(
      
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color:Colors.grey,
                      fontSize: 30,),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: HexColor(backgroundColor
                      ),
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: HexColor(buttonColor))
                    )
                  );
  }
}
