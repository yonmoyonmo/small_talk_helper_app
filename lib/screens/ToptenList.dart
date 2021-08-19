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

  get colorCodes => null;

  Future<SugguestionList> getRandomSugguestionList() async {
    final response =
        await http.get(new SmallTalkHelperEndpoint().getEndpoint("topten"));
    if (response.statusCode == 200) {
      return SugguestionList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("failed to fetch SugguestionList");
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
              child: FutureBuilder(
                future: sugguestionList,
                builder: (BuildContext context,
                    AsyncSnapshot<SugguestionList> snapshot) {
                  if (snapshot.hasData) {
                    for (int i = 0;
                        i < snapshot.data!.sugguestions.length;
                        i++) {
                      print(snapshot.data!.sugguestions[i].sugguestionText);
                    }
                    return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: snapshot.data!.sugguestions.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 50,
                            child: Center(
                                child: Text(
                                    '${snapshot.data!.sugguestions[index].sugguestionText}' +
                                        " " +
                                        '${snapshot.data!.sugguestions[index].countLikes}')),
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                },
              ),
            )));
  }
}
