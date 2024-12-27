import 'package:dio/dio.dart';

class TripModel {
  // 일정 생성
  Future<String> insertTrip(Map<String, dynamic> tripData) async {
    final dio = Dio();

    try {
      final responses =
          await dio.post("http://localhost:8082/trip/insert", data: tripData);
      if (responses.statusCode == 200) {
        print(responses);
        return "일정 생성에 성공했습니다.";
      } else {
        return "일정 생성에 실패했습니다.";
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }
}
