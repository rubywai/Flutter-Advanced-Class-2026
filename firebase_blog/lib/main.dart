import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_blog/analytics/analytics_utils.dart';
import 'package:firebase_blog/data/login_utils.dart';
import 'package:firebase_blog/screens/home_screen.dart';
import 'package:firebase_blog/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
//login, auth
//google , apple login (social login)
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  runApp(const MyApp());
}

//Events (ScreenView, CustomEvent)
//UserProperties

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  User? _user;
  @override
  void initState() {
    super.initState();
    _voidLogUserInfo();
    listenAuthState((User? user) {
      setState(() {
        _user = user;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: _analytics),
      ],
      debugShowCheckedModeBanner: false,
      home: _user == null ? LoginScreen() :  HomeScreen(),
    );
  }
  void _voidLogUserInfo(){
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      AnalyticsUtils.logUserInfo(user.displayName ?? '', user.email ?? '');
    }
  }
}

