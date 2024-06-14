import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:remember_medicine/page/auth/account.dart';
import 'package:remember_medicine/const/color.dart';
import "package:email_validator/email_validator.dart";

class Login_page extends StatefulWidget {
  const Login_page({Key? key}) : super(key: key);

  @override
  State<Login_page> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login_page> {

  late String email,password;
  final formKey=GlobalKey<FormState>();
  

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
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleText(),
                    customSizeBox(),
                    mailtextfield(),
                    customSizeBox(),
                    passwordtextfield(),
                    customSizeBox(),
                    signInButton(),
                    customSizeBox(),
                    createAccountButton(),
                    customSizeBox(),
                    forgotPasswordButton(),
                
                
                    
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
      "GİRİŞ YAP ",
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

   
    Center forgotPasswordButton(){
      return Center(
        child: TextButton(
          onPressed: (){},
           child: Text(
                      "Şifremi Unuttum",style: TextStyle(
                        color:HexColor(primaryColor),
                        fontSize: 30,
                        fontStyle: FontStyle.italic,
                      ),
                      ),
                      )
      );
    }

    Center createAccountButton(){
      return Center(
        child: ElevatedButton.icon(
         onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context)=>const AccountPage(),
            ),
            );
         },
         label: Text("Hesap Oluştur",
         style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
         ),
          ),
            icon: Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
                 style: ElevatedButton.styleFrom(
                 backgroundColor: HexColor(buttonColor),
                 padding: EdgeInsets.symmetric(horizontal: 20),
                 shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(10)),
           ),
           ),
           );
    }

    Center signInButton(){
      return  Center(
        child: ElevatedButton.icon(
           onPressed: () async {
            if(formKey.currentState!.validate()){
              formKey.currentState!.save();
              try{

              }
              catch(e){
                print(e.toString());
              }
              
            }
            else{

            }
           },
           label: Text("Giriş Yap",style: TextStyle(
                       color: Colors.white,
                        fontSize: 30.0,
                        ),
                        ),
                  icon: Icon(
                    Icons.check, color: Colors.white),
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
