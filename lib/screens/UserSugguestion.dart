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

  @override
  Widget build(BuildContext context) {
    if (afterJob) {
      return SafeArea(
          child: Scaffold(
        appBar: AppBar(
          title: Text("아이폰에는 뒤로가기 없다"),
        ),
        body: Text("뒤로 가세요 제발 짜증나게 하지 말고"),
      ));
    } else {
      return SafeArea(
          child: Scaffold(
        appBar: AppBar(
          title: Text("아이폰에는 뒤로가기 없다"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(8),
              child: Text("user sugguestion"),
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'your name',
              ),
              controller: userNameController,
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'your sugguestion',
              ),
              controller: userSugguestionController,
            ),
            FloatingActionButton(
              child: Icon(Icons.mail),
              onPressed: _submit,
            )
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
            return AlertDialog(content: Text("내용 입력 요망"));
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
              return AlertDialog(content: Text("잘 보내졌읍니다."));
            });
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(content: Text("실패함 ㅋ"));
            });
      }
    }
  }

  Future<bool> _sendSugguestion() async {
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
  }
}
