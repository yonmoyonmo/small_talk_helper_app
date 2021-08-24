import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:small_talk_helper_app/utils/SmallTalkHelperEndpoint.dart';

class UserSugguestion extends StatefulWidget {
  const UserSugguestion({Key? key}) : super(key: key);
  @override
  _UserSugguestionState createState() => _UserSugguestionState();
}

class _UserSugguestionState extends State<UserSugguestion> {
  final userNameController = TextEditingController();
  final userSugguestionController = TextEditingController();

  late var afterJob = false;

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    primary: Colors.black87,
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );
  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    onPrimary: Colors.black87,
    primary: Colors.grey[300],
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (afterJob) {
      return SafeArea(
          child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: TextButton(
              style: flatButtonStyle,
              child: Text(
                "뒤로가기",
                style: TextStyle(fontSize: 30),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              }),
        ),
      ));
    } else {
      return SafeArea(
          child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "개발자에게 대화 주제 추천하기",
            style: TextStyle(fontSize: 15),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              margin: EdgeInsets.all(12),
              color: Colors.grey[200],
              child: Padding(
                padding: EdgeInsets.all(12),
                child: TextField(
                  controller: userNameController,
                  maxLines: 1,
                  decoration: InputDecoration.collapsed(
                      hintText: "대화 주제와 함께 기록될 이름을 입력해 주세요!"),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.all(12),
              color: Colors.grey[200],
              child: Padding(
                padding: EdgeInsets.all(12),
                child: TextField(
                  controller: userSugguestionController,
                  maxLines: 8,
                  decoration: InputDecoration.collapsed(
                    hintText: "대화 주제를 입력해 주세요!",
                  ),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(12),
              width: 100,
              alignment: Alignment.center,
              child: ElevatedButton(
                style: raisedButtonStyle,
                child: Text(
                  "보내기",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ));
    }
  }

  Future<void> _submit() async {
    if (userNameController.text.isEmpty ||
        userSugguestionController.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(content: Text("내용을 입력해 주세요!"));
          });
    } else {
      var result = await _sendSugguestion();
      if (result) {
        setState(() {
          afterJob = true;
        });
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                title: Column(
                  children: <Widget>[
                    new Text("감사합니당!"),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "보내 주신 대화 주제는 검토 후 입력하신 이름과 함께 등록해 놓을게용!",
                    ),
                  ],
                ),
                actions: <Widget>[
                  new TextButton(
                    style: flatButtonStyle,
                    child: new Text("홈으로 돌아가기"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/home');
                    },
                  ),
                ],
              );
            });
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                title: Column(
                  children: <Widget>[
                    new Text("문제가 생겼습니다!"),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "전송에 문제가 생겼습니다! 나중에 다시 시도해 주세요!",
                    ),
                  ],
                ),
                actions: <Widget>[
                  new TextButton(
                    style: flatButtonStyle,
                    child: new Text("홈으로 돌아가기"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/home');
                    },
                  ),
                ],
              );
            });
      }
    }
  }

  Future<bool> _sendSugguestion() async {
    try {
      final response = await http.post(
          new SmallTalkHelperEndpoint().getEndpoint("users-sugguestion"),
          body: jsonEncode({
            "userName": userNameController.text,
            "text": userSugguestionController.text
          }),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("failed to upload user's sugguestion");
      }
    } on Exception {
      return false;
    }
  }
}
