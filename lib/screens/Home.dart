import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:small_talk_helper_app/payloads/sugguestion.dart';
import 'package:small_talk_helper_app/utils/SmallTalkHelperEndpoint.dart';
import 'package:like_button/like_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

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

  final String iOSTestId = 'ca-app-pub-3940256099942544/2934735716';
  final String androidTestId = 'ca-app-pub-3940256099942544/6300978111';
  late BannerAd banner;
  late AdWidget adWidget;
  //late Container adContainer;

  @override
  void initState() {
    super.initState();

    //초기화 에러 방지용 무용지물 코드
    _isLiked = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('$sugguestionId') ?? false;
    });

    banner = BannerAd(
      size: AdSize.banner,
      adUnitId: Platform.isIOS ? iOSTestId : androidTestId,
      listener: BannerAdListener(),
      request: AdRequest(),
    )..load();

    adWidget = AdWidget(ad: banner);

    // adContainer = Container(
    //   alignment: Alignment.center,
    //   child: adWidget,
    //   width: banner.size.width.toDouble(),
    //   height: banner.size.height.toDouble(),
    // );

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
            //print(sugguestionId);
            return prefs.getBool('$sugguestionId') ?? false;
          });
        });
        return result;
      } else {
        throw Exception("failed to fetch Sugguestion");
      }
    } catch (Exception) {
      print(Exception);
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
    try {
      final SharedPreferences prefs = await _prefs;
      int likeValue = 1;

      //print("liked : " + liked.toString());
      //print("preference key : " + prefs.containsKey('$sugguestionId').toString());

      if (liked) {
        likeValue = -1;
        final response = await http.post(
            smallTalkHelperEndpoint.getEndpoint("likes"),
            body: jsonEncode(
                {"sugguestionId": sugguestionId, "likeValue": likeValue}),
            headers: {"Content-Type": "application/json"});
        if (response.statusCode == 200) {
          setState(() {
            _isLiked =
                prefs.setBool('$sugguestionId', false).then((bool result) {
              //print("result : " + result.toString());
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
            _isLiked =
                prefs.setBool('$sugguestionId', true).then((bool result) {
              //print("result : " + result.toString());
              return true;
            });
          });
          return true;
        } else {
          throw Exception("failed to apply user's like");
        }
      }
    } on Exception {
      return liked;
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
                  height: 200,
                  child: DrawerHeader(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 100,
                          child: Image(
                            image: AssetImage('images/STHAppIcon2.png'),
                          ),
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
                  title: Text(
                    '인기 짱 대화 주제 TOP 10',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/topten');
                  },
                ),
                ListTile(
                  title: Text(
                    '개발자에게 대화 주제 추천하기',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: FutureBuilder(
                    future: sugguestion,
                    builder: (BuildContext context,
                        AsyncSnapshot<Sugguestion> snapshot) {
                      if (snapshot.hasData) {
                        return AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                child: child, scale: animation);
                          },
                          child: Container(
                              key: ValueKey<int>(snapshot.data!.id),
                              width: MediaQuery.of(context).size.width - 80,
                              height: MediaQuery.of(context).size.height / 2,
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.all(10),
                              color: Colors.white,
                              child: Center(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    children: [
                                      Text(
                                        snapshot.data!.sugguestionText,
                                        style: TextStyle(
                                          fontSize: 25,
                                          height: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        );
                      } else if (snapshot.hasError) {
                        //print('${snapshot.error}');
                        return Text("error");
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 80,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: _getSugguestionTap,
                        icon: Icon(
                          Icons.shuffle,
                          size: 70,
                          color: Colors.black,
                        ),
                        label: Text(""),
                      ),
                      FutureBuilder<bool>(
                        future: _isLiked,
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return LikeButton(
                                  size: 70,
                                  isLiked: false,
                                  likeBuilder: (bool isLiked) {
                                    return Icon(
                                      Icons.favorite,
                                      color: isLiked ? Colors.red : Colors.grey,
                                      size: 70,
                                    );
                                  });
                            default:
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return LikeButton(
                                  size: 70,
                                  isLiked: snapshot.data,
                                  circleColor: CircleColor(
                                      start: Colors.black, end: Colors.red),
                                  bubblesColor: BubblesColor(
                                    dotPrimaryColor: Colors.grey,
                                    dotSecondaryColor: Colors.black,
                                  ),
                                  likeBuilder: (bool isLiked) {
                                    return Icon(
                                      Icons.favorite,
                                      color: isLiked ? Colors.red : Colors.grey,
                                      size: 70,
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
                Container(
                  alignment: Alignment.center,
                  child: adWidget,
                  width: banner.size.width.toDouble(),
                  height: banner.size.height.toDouble(),
                ),
              ],
            ),
          )),
    );
  }
}
