import 'package:dio/dio.dart';
import 'package:flutter_locatrip/map/model/place.dart';

class LocationModel {
  Future<dynamic> insertLocation(Map<String, dynamic> place) async {
    final dio = Dio();

    try {
      // final responses = await dio.post("http://192.168.45.79:8082/location/insert",
      final responses = await dio
          .post("http://112.221.66.174:1234/location/insert", data: place);
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
      // final responses = await dio.post("http://192.168.45.79:8082/location/deleteFavorite",
      final responses = await dio.post(
          "http://112.221.66.174:1234/location/deleteFavorite",
          data: place);
      if (responses.statusCode == 200) {
        return responses.data as Map<String, dynamic>;
      } else {
        return "내 장소 삭제에 실패했습니다.";
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }
}
