import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:small_talk_helper_app/Utils/SmallTalkHelperEndpoint.dart';
import 'package:small_talk_helper_app/payloads/SugguestionList.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Favorite extends StatefulWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  late Future<SugguestionList> sugguestionList;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late var sugguestionId;

  @override
  void initState() {
    super.initState();
    sugguestionList = getFavoriteSugguestionList();
  }

  Future<SugguestionList> getFavoriteSugguestionList() async {
    SharedPreferences prefs = await _prefs;
    var tmpList = prefs.getStringList("favorite");
    print("favorite debug : " + tmpList.toString());
    try {
      final response = await http.post(
          new SmallTalkHelperEndpoint().getEndpoint("favorite"),
          body: jsonEncode({"favoriteList": tmpList ?? []}),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        return SugguestionList.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("failed to fetch SugguestionList");
      }
    } on Exception {
      Map<String, dynamic> failed = {
        "id": 0,
        "sugguestion_type": "no",
        "sugguestion_text": "대화 주제를 불러올 수 없습니다.",
        "count_likes": 0,
        "created_at": "no",
      };
      List<dynamic> failedList = [];
      failedList.add(failed);
      SugguestionList result = SugguestionList.fromJson(failedList);
      return result;
    }
  }

  void applyLikes() async {
    try {
      final SharedPreferences prefs = await _prefs;

      final response = await http.post(
          new SmallTalkHelperEndpoint().getEndpoint("likes"),
          body: jsonEncode({"sugguestionId": sugguestionId, "likeValue": -1}),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        var favList = prefs.getStringList("favorite");
        for (int i = 0; i < favList!.length; i++) {
          var element = favList[i];
          if (element == '$sugguestionId') {
            favList.removeAt(i);
          }
        }
        await prefs.setBool('$sugguestionId', false);
        var debug = await prefs.setStringList("favorite", favList);
        print("favorite unlike : " + debug.toString());
        print(favList);
        setState(() {
          sugguestionList = getFavoriteSugguestionList();
        });
      }
    } catch (e) {
      print(e);
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
            body: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: FutureBuilder(
                future: sugguestionList,
                builder: (BuildContext context,
                    AsyncSnapshot<SugguestionList> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.sugguestions.length == 0) {
                      return Center(
                        child: Text(
                          "아직 하트를 누른 대화 주제가 하나도 없어염!",
                          style: TextStyle(fontSize: 16, height: 2),
                        ),
                      );
                    }
                    return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: snapshot.data!.sugguestions.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            trailing: TextButton(
                              onPressed: () {
                                print("000000");
                                setState(() {
                                  sugguestionId =
                                      snapshot.data!.sugguestions[index].id;
                                });
                                applyLikes();
                              },
                              child: Text("제거"),
                            ),
                            title: Text(
                              '${snapshot.data!.sugguestions[index].sugguestionText}',
                              style: TextStyle(fontSize: 16, height: 2),
                            ),
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return Center(child: const CircularProgressIndicator());
                },
              ),
            )));
  }
}
