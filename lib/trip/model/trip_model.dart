import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../common/Auth/auth_dio_interceptor.dart';
import '../../common/widget/url.dart';

// 일정 관련
class TripModel {
  // 일정 생성
  Future<dynamic> insertTrip(
      Map<String, dynamic> tripData, BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final responses = await dio.post("$backUrl/trip/insert", data: tripData);
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
  Future<Map<String, dynamic>> selectTrip(
      int tripId, BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final responses = await dio.get(
        "$backUrl/trip/select/$tripId",
      );
      if (responses.statusCode == 200) {
        print('responses.data ${responses.data}');
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
