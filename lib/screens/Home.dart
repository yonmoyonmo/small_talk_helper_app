import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:small_talk_helper_app/payloads/sugguestion.dart';
import 'package:small_talk_helper_app/utils/SmallTalkHelperEndpoint.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var testText = "";
  var count = 0;

  late Future<Sugguestion> sugguestion;

  Future<Sugguestion> getRandomSugguestion() async {
    final response =
        await http.get(new SmallTalkHelperEndpoint().getEndpoint("random"));
    if (response.statusCode == 200) {
      return Sugguestion.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("failed to fetch Sugguestion");
    }
  }

  @override
  void initState() {
    super.initState();
    sugguestion = getRandomSugguestion();
  }

  Future<void> _onTap() async {
    setState(() {
      testText = "tapped";
      count = count + 1;
      sugguestion = getRandomSugguestion();
    });
    print(testText + count.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Container(
        alignment: Alignment.center,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text("TOPTEN"),
                onPressed: () {
                  Navigator.pushNamed(context, '/topten');
                },
              ),
              ElevatedButton(
                child: Text("user's sugguestion"),
                onPressed: () {
                  Navigator.pushNamed(context, '/users-sugguestion');
                },
              ),
              Text(count.toString()),
              GestureDetector(
                  onTap: _onTap,
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Color.fromRGBO(10, 190, 23, 1),
                    child: Text(
                      testText,
                    ),
                  )),
              Container(
                child: FutureBuilder(
                  future: sugguestion,
                  builder: (BuildContext context,
                      AsyncSnapshot<Sugguestion> snapshot) {
                    if (snapshot.hasData) {
                      print(snapshot.data!.sugguestionText);
                      return Text(snapshot.data!.sugguestionText);
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
