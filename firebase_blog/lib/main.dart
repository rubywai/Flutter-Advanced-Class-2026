import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_blog/data/login_utils.dart';
import 'package:firebase_blog/screens/home_screen.dart';
import 'package:firebase_blog/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//login, auth
//google , apple login (social login)
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? _user;
  @override
  void initState() {
    super.initState();
    listenAuthState((User? user) {
      setState(() {
        _user = user;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _user == null ? LoginScreen() :  HomeScreen(),
    );
  }
}

