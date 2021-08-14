import 'package:flutter/material.dart';

class SmallTalkHelperHome extends StatefulWidget {
  SmallTalkHelperHome({Key? key}) : super(key: key);
  @override
  _SmallTalkHelperHomeState createState() => _SmallTalkHelperHomeState();
}

class _SmallTalkHelperHomeState extends State<SmallTalkHelperHome>
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
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      // alignment: Alignment.center,
      // turns: _animationController,
      position: _offsetAnimation,
      child: Scaffold(
        body: Container(
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
