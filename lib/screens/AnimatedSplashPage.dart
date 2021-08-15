import 'dart:async';
import 'package:flutter/material.dart';

import 'Home.dart';

class AnimatedSplashPage extends StatefulWidget {
  AnimatedSplashPage({Key? key}) : super(key: key);
  @override
  _AnimatedSplashPageState createState() => _AnimatedSplashPageState();
}

class _AnimatedSplashPageState extends State<AnimatedSplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  ));

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlideTransition(
        // alignment: Alignment.center,
        // turns: _animationController,
        position: _offsetAnimation,
        child: Container(
          alignment: Alignment.center,
          child: Text("test"),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
