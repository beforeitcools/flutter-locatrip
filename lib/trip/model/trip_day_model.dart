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

  // 조회
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

  // 순서 저장시키기
  Future<List<Map<String, dynamic>>> saveTripDayIndex(
      List<Map<String, dynamic>> placeData, BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final responses = await dio.post("$backUrl/tripDay/saveTripDayIndex",
          data: jsonEncode(placeData));

      if (responses.statusCode == 200) {
        print('responsese ${responses.data}');
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

  Future<bool> deleteTripDay(List<int> placeId, BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final responses = await dio.post("$backUrl/tripDay/deleteTripDay",
          data: jsonEncode(placeId));

      if (responses.statusCode == 200) {
        print('responsese ${responses.data}');
        return responses.data;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }

  Future<int> getTripDayCount(int tripId, BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final responses =
          await dio.get("$backUrl/tripDay/getTripDayCount/$tripId");

      if (responses.statusCode == 200) {
        print('responsese ${responses.data}');
        return responses.data;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }
}
