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
      duration: Duration(seconds: 10),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: 200,
                alignment: Alignment.center,
                child: Image(
                  image: AssetImage("images/SmallTalkHelperAppIcon.png"),
                )),
            Container(
              alignment: Alignment.center,
              child: Text(
                "스몰 토크 헬퍼",
                style: TextStyle(
                  fontSize: 40,
                  height: 2,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                "by wonmonae",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
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
