import 'package:flutter/material.dart';
import 'package:small_talk_helper_app/screens/AnimatedSplashPage.dart';
import 'package:small_talk_helper_app/screens/Donate.dart';
import 'package:small_talk_helper_app/screens/Favorite.dart';
import 'package:small_talk_helper_app/screens/Home.dart';
import 'package:small_talk_helper_app/screens/Love36Page.dart';
import 'package:small_talk_helper_app/screens/ToptenList.dart';
import 'package:small_talk_helper_app/screens/UserSugguestion.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flutter/foundation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Small_Talk_Helper',
      theme: ThemeData(
          primaryColor: Colors.white,
          primarySwatch: Colors.grey,
          fontFamily: 'DungGeunMo'),
      initialRoute: '/',
      routes: {
        '/': (context) => AnimatedSplashPage(),
        '/home': (context) => Home(),
        '/topten': (context) => ToptenList(),
        '/users-sugguestion': (context) => UserSugguestion(),
        '/love36': (context) => Love36Page(),
        '/favorite': (context) => Favorite(),
        '/donate': (context) => Donate(),
      },
    );
  }
}
