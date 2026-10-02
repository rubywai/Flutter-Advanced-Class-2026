import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsUtils {
  static void logUserInfo(String name,String email){
    FirebaseAnalytics.instance.setUserProperty(name: 'name', value: name);
    FirebaseAnalytics.instance.setUserProperty(name: 'email', value: email);
  }
  static void customEvent(String name, String value){
    FirebaseAnalytics.instance.logEvent(name: name, parameters: {'value': value});
  }
}