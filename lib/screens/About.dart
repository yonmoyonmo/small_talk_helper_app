import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "앱을 삭제하게 되면 영향 받는 것 두 가지에 대한 간단한 설명입니다.\n",
                    style: TextStyle(fontSize: 16, height: 2),
                  ),
                  Text(
                    "즐겨찾기",
                    style: TextStyle(fontSize: 20, height: 2),
                  ),
                  Text(
                    "하트 아이콘을 눌러서 즐겨찾기를 저장할 수 있습니다. 저장된 즐겨찾기는 앱을 삭제하면 모두 초기화됩니다.\n",
                    style: TextStyle(fontSize: 16, height: 2),
                  ),
                  Text(
                    "광고 제거",
                    style: TextStyle(fontSize: 20, height: 2),
                  ),
                  Text(
                    "개발자의 구걸 깡통에 인심을 베푸시면 광고 배너가 사라집니다! 그러나 앱을 삭제하시고 다시 설치하시게 되면 다시 광고 배너가 나타나게 됩니다.\n",
                    style: TextStyle(fontSize: 16, height: 2),
                  ),
                  Text(
                    "아니 이 개발자놈이 왜 삭제하면 다 초기화되게 만들었을까요?!!",
                    style: TextStyle(fontSize: 16, height: 2),
                  ),
                  Text(
                    "그 이유는 바로바로...",
                    style: TextStyle(fontSize: 16, height: 2),
                  ),
                  Text(
                    "거지 개발자의 서버 비용 절약이었습니다! 여러분들께서 많은 성원으로 응원해 주신다면 앱 삭제로 초기화되지 않도록 해보겠습니다!\n",
                    style: TextStyle(fontSize: 16, height: 2),
                  ),
                  Text(
                    "사랑하는 앱 사용자 여러분들 감사합니다!",
                    style: TextStyle(fontSize: 16, height: 2),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
