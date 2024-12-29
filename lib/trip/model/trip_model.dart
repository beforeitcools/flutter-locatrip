import 'package:dio/dio.dart';

// 일정 관련
class TripModel {
  // 일정 생성
  Future<dynamic> insertTrip(Map<String, dynamic> tripData) async {
    final dio = Dio();

    try {
      final responses = await dio.post("http://192.168.45.150:8082/trip/insert",
          data: tripData);
      if (responses.statusCode == 200) {
        return responses.data as Map<String, dynamic>;
      } else {
        return "일정 생성에 실패했습니다.";
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }

  // 일정 조회
  Future<Map<String, dynamic>> selectTrip(int tripId) async {
    final dio = Dio();
    try {
      final responses = await dio.get(
        "http://192.168.45.150:8082/trip/select/$tripId",
      );
      if (responses.statusCode == 200) {
        return responses.data as Map<String, dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }
}
