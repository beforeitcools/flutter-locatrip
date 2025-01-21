import 'dart:convert';

class JsonParser {
  //json 변경 메소드
  String convertToJSONString(dynamic data) {
    String jsonString = jsonEncode(data);
    print("데이터를 String 타입으로 바꾸겠긔");
    return jsonString;
  }

  List<Map<String, dynamic>> convertToList(String jsonString) {
    List<Map<String, dynamic>> tripDayRslt =
        List<Map<String, dynamic>>.from(jsonDecode(jsonString));
    return tripDayRslt;
  }
}
