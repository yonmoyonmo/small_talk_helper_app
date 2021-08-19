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
    try {
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
    } on Exception {
      var failed = jsonEncode({
        "id": 0,
        "sugguestion_type": "no",
        "sugguestion_text": "대화 주제를 불러올 수 없습니다.",
        "count_likes": 0,
        "created_at": "no",
      });
      Sugguestion result = Sugguestion.fromJson(jsonDecode(failed));
      return result;
    }
  }

  Future<void> _getSugguestionTap() async {
    setState(() {
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
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                Container(
                  height: 400,
                  child: DrawerHeader(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image(
                          image: AssetImage('images/wonmonaeLogo.png'),
                        ),
                        Text(
                          "스몰 토크 헬퍼",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "small talk helper",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  title: Text('topten'),
                  onTap: () {
                    Navigator.pushNamed(context, '/topten');
                  },
                ),
                ListTile(
                  title: Text('users-sugguestion'),
                  onTap: () {
                    Navigator.pushNamed(context, '/users-sugguestion');
                  },
                )
              ],
            ),
          ),
          body: Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            alignment: Alignment.center,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: FutureBuilder(
                      future: sugguestion,
                      builder: (BuildContext context,
                          AsyncSnapshot<Sugguestion> snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                              width: MediaQuery.of(context).size.width - 100,
                              height: 400,
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.all(10),
                              color: Colors.white,
                              child: Center(
                                child: Text(
                                  snapshot.data!.sugguestionText,
                                  style: TextStyle(
                                    fontSize: 30,
                                    height: 1,
                                  ),
                                ),
                              ));
                        } else if (snapshot.hasError) {
                          print('${snapshot.error}');
                          return Text("error");
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 100,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _getSugguestionTap,
                          child: Container(
                            width: 100,
                            height: 100,
                            color: Colors.white,
                            child: Center(
                              child: Icon(
                                Icons.shuffle,
                                size: 100,
                              ),
                            ),
                          ),
                        ),
                        FutureBuilder<bool>(
                          future: _isLiked,
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return LikeButton(
                                    size: 100,
                                    isLiked: false,
                                    likeBuilder: (bool isLiked) {
                                      return Icon(
                                        Icons.favorite,
                                        color:
                                            isLiked ? Colors.red : Colors.grey,
                                        size: 100,
                                      );
                                    });
                              default:
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return LikeButton(
                                    size: 100,
                                    isLiked: snapshot.data,
                                    likeBuilder: (bool isLiked) {
                                      return Icon(
                                        Icons.favorite,
                                        color:
                                            isLiked ? Colors.red : Colors.grey,
                                        size: 100,
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
                  )
                ],
              ),
            ),
          )),
    );
  }
}
