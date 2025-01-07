import 'package:dio/dio.dart';
import 'package:flutter_locatrip/map/model/place.dart';

class LocationModel {
  String backUrl = "http://192.168.45.56:8082"; // 집
  // String backUrl = "http://112.221.66.174:1234"; // 학원

  Future<dynamic> insertLocation(Map<String, dynamic> place) async {
    final dio = Dio();
    print('insert!!');
    try {
      final responses = await dio.post("$backUrl/location/insert", data: place);
      if (responses.statusCode == 200) {
        return responses.data as Map<String, dynamic>;
      } else {
        return "장소 저장에 실패했습니다.";
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }

  Future<dynamic> deleteFavorite(Map<String, dynamic> place) async {
    final dio = Dio();

    try {
      final responses =
          await dio.post("$backUrl/location/deleteFavorite", data: place);
      if (responses.statusCode == 200) {
        return responses.data as Map<String, dynamic>;
      } else {
        return {"status": "fail", "message": "내 장소 삭제에 실패했습니다."};
      }
    } catch (e) {
      throw Exception("Error : $e");
      return {"status": "fail", "message": "서버와의 연결 중 오류가 발생했습니다."};
    }
  }
}
