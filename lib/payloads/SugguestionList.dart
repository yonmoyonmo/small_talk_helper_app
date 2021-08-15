import 'package:small_talk_helper_app/payloads/sugguestion.dart';

class SugguestionList {
  final List<Sugguestion> sugguestions;

  SugguestionList({required this.sugguestions});

  factory SugguestionList.fromJson(List<dynamic> json) {
    late List<Sugguestion> sugguestionsFromJson = [];
    for (int i = 0; i < json.length; i++) {
      Sugguestion sugguestion = Sugguestion.fromJson(json[i]);
      sugguestionsFromJson.add(sugguestion);
    }
    return SugguestionList(sugguestions: sugguestionsFromJson);
  }
}
