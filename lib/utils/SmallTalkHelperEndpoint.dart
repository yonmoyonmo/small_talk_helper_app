class SmallTalkHelperEndpoint {
  final String host =
      "https://small-talk-helper.wonmonae.com/api/sugguestion/small-talk-helper/";

  Uri getEndpoint(String endpointName) {
    String uri = this.host + endpointName;
    return Uri.parse(uri);
  }
}
