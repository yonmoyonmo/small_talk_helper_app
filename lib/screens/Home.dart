import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:small_talk_helper_app/payloads/sugguestion.dart';
import 'package:small_talk_helper_app/utils/SmallTalkHelperEndpoint.dart';
import 'package:like_button/like_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var testText = "";
  var sugguestionId = 0;
  var likeValue;

  late Future<Sugguestion> sugguestion;
  late SmallTalkHelperEndpoint smallTalkHelperEndpoint =
      new SmallTalkHelperEndpoint();

  late Future<bool> _isLiked;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();

    //초기화 에러 방지용 무용지물 코드
    _isLiked = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('$sugguestionId') ?? false;
    });

    sugguestion = getRandomSugguestion();
  }

  Future<Sugguestion> getRandomSugguestion() async {
    final response =
        await http.get(smallTalkHelperEndpoint.getEndpoint("random"));
    if (response.statusCode == 200) {
      Sugguestion result = Sugguestion.fromJson(jsonDecode(response.body));
      setState(() {
        sugguestionId = result.id;
        _isLiked = _prefs.then((SharedPreferences prefs) {
          print(sugguestionId);
          return prefs.getBool('$sugguestionId') ?? false;
        });
      });
      return result;
    } else {
      throw Exception("failed to fetch Sugguestion");
    }
  }

  Future<void> _getSugguestionTap() async {
    setState(() {
      testText = "tapped";
      sugguestion = getRandomSugguestion();
    });
  }

  Future<bool> applyLikes(bool liked) async {
    final SharedPreferences prefs = await _prefs;
    int likeValue = 1;

    print("liked : " + liked.toString());
    print("preference key : " + prefs.containsKey('$sugguestionId').toString());

    if (liked) {
      likeValue = -1;
      final response = await http.post(
          smallTalkHelperEndpoint.getEndpoint("likes"),
          body: jsonEncode(
              {"sugguestionId": sugguestionId, "likeValue": likeValue}),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          _isLiked = prefs.setBool('$sugguestionId', false).then((bool result) {
            print("result : " + result.toString());
            return false;
          });
        });
        return true;
      } else {
        throw Exception("failed to apply user's like");
      }
    } else {
      final response = await http.post(
          smallTalkHelperEndpoint.getEndpoint("likes"),
          body: jsonEncode(
              {"sugguestionId": sugguestionId, "likeValue": likeValue}),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          _isLiked = prefs.setBool('$sugguestionId', true).then((bool result) {
            print("result : " + result.toString());
            return true;
          });
        });
        return true;
      } else {
        throw Exception("failed to apply user's like");
      }
    }
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
              Container(
                child: FutureBuilder(
                  future: sugguestion,
                  builder: (BuildContext context,
                      AsyncSnapshot<Sugguestion> snapshot) {
                    if (snapshot.hasData) {
                      // WidgetsBinding.instance!.addPostFrameCallback((_) {
                      //   setState(() {
                      //     sugguestionId = snapshot.data!.id;
                      //   });
                      // });
                      return Container(
                        width: 200,
                        height: 200,
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(10),
                        color: Colors.amber,
                        child: Center(
                            child: Text(snapshot.data!.sugguestionText +
                                " : " +
                                snapshot.data!.countLikes.toString())),
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}' +
                          " : " +
                          sugguestionId.toString());
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ),
              GestureDetector(
                onTap: _getSugguestionTap,
                child: Container(
                  width: 100,
                  height: 50,
                  color: Color.fromRGBO(10, 190, 23, 1),
                  child: Center(
                    child: Text(
                      testText,
                    ),
                  ),
                ),
              ),
              FutureBuilder<bool>(
                future: _isLiked,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    default:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return LikeButton(
                          size: 50,
                          isLiked: snapshot.data,
                          likeBuilder: (bool isLiked) {
                            return Icon(
                              Icons.favorite,
                              color: isLiked ? Colors.red : Colors.grey,
                              size: 50,
                            );
                          },
                          onTap: applyLikes,
                        );
                      }
                  }
                },
              ),
            ],
          ),
        ),
      )),
    );
  }
}
