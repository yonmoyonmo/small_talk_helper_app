import 'package:flutter/material.dart';
import 'package:small_talk_helper_app/screens/AnimatedSplashPage.dart';
import 'package:small_talk_helper_app/screens/Favorite.dart';
import 'package:small_talk_helper_app/screens/Home.dart';
import 'package:small_talk_helper_app/screens/ToptenList.dart';
import 'package:small_talk_helper_app/screens/UserSugguestion.dart';

void main() {
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
          primarySwatch: Colors.blue,
          fontFamily: 'DungGeunMo'),
      initialRoute: '/',
      routes: {
        '/': (context) => AnimatedSplashPage(),
        '/home': (context) => Home(),
        '/topten': (context) => ToptenList(),
        '/favorite': (context) => Favorite(),
        '/users-sugguestion': (context) => UserSugguestion(),
      },
    );
  }
}
