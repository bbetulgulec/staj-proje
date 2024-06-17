import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth mAuth = FirebaseAuth.instance;
  late DatabaseReference userRef;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  void _fetchUserName() async {
    User? currentUser = mAuth.currentUser;
    if (currentUser != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(currentUser.uid);
      userRef.once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        setState(() {
          if (snapshot.value != null) {
            Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
            userName = userData['name'];
          } else {
            userName = 'User data not found';
          }
        });
      }).catchError((error) {
        print('Failed to fetch user data: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Stack(
        children:
        [ 
            Text(
            userName.isNotEmpty ? userName : 'Loading...',
            style: TextStyle(fontSize: 24),
          
        ),
        ]
      ),
    );
  }
}
