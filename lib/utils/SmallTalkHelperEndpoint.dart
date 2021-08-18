class SmallTalkHelperEndpoint {
  final String host = "http://172.30.1.35:5000/sugguestion/small-talk-helper/";

  Uri getEndpoint(String endpointName) {
    String uri = this.host + endpointName;
    return Uri.parse(uri);
  }
}
