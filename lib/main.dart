import 'package:flutter/material.dart';
import 'package:small_talk_helper_app/screens/AnimatedSplashPage.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: AnimatedSplashPage(),
    );
  }
}
