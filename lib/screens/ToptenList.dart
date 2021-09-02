import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:small_talk_helper_app/Utils/SmallTalkHelperEndpoint.dart';
import 'package:small_talk_helper_app/payloads/SugguestionList.dart';
import 'package:http/http.dart' as http;

class ToptenList extends StatefulWidget {
  const ToptenList({Key? key}) : super(key: key);
  @override
  _ToptenListState createState() => _ToptenListState();
}

class _ToptenListState extends State<ToptenList> {
  late Future<SugguestionList> sugguestionList;

  //get colorCodes => null;

  Future<SugguestionList> getRandomSugguestionList() async {
    try {
      final response =
          await http.get(new SmallTalkHelperEndpoint().getEndpoint("topten"));
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

  @override
  void initState() {
    super.initState();
    sugguestionList = getRandomSugguestionList();
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
                    for (int i = 0;
                        i < snapshot.data!.sugguestions.length;
                        i++) {
                      //print(snapshot.data!.sugguestions[i].sugguestionText);
                    }
                    return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: snapshot.data!.sugguestions.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: Text(
                              (index + 1).toString(),
                              style: TextStyle(fontSize: 16),
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
