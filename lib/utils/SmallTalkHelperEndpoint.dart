class SmallTalkHelperEndpoint {
  final String host =
      "https://small-talk-helper.wonmocyberschool.com/api/sugguestion/small-talk-helper/";
  // final String host =
  //     "https://small-talk-helper.wonmonae.com/api/sugguestion/small-talk-helper/";

  // final String host =
  //     "http://172.30.1.4:5000/api/sugguestion/small-talk-helper/";

  Uri getEndpoint(String endpointName) {
    String uri = this.host + endpointName;
    return Uri.parse(uri);
  }
}
