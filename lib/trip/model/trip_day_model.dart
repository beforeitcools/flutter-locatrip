import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../common/Auth/auth_dio_interceptor.dart';
import '../../common/widget/url.dart';

class TripDayModel {
  // 날짜별 장소 추가
  Future<Map<String, dynamic>> saveTripDayLocation(
      Map<String, dynamic> data, BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final responses = await dio.post("$backUrl/tripDay/saveTripDayLocation",
          data: jsonEncode(data));
      print('responsese $responses');
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

  Future<List<Map<String, dynamic>>> getTripDay(
      int tripId, BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      print('요청시작');
      final responses = await dio.get(
        "$backUrl/tripDay/selectTripDayLocation/$tripId",
      );

      if (responses.statusCode == 200) {
        // 요청받음
        print('responsese $responses.data');
        final List<dynamic> responseData = responses.data;
        final List<Map<String, dynamic>> result =
            responseData.map((item) => item as Map<String, dynamic>).toList();

        return result;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }
}
