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
        return responses.data as Map<String, dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }

  // 메모 등록
  Future<Map<String, dynamic>> addMemo(
      Map<String, dynamic> data, BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final responses = await dio.post("$backUrl/memo/insertMemo", data: data);
      print('responses memo $responses.data');
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

  // 메모 조회
  Future<List<Map<String, dynamic>>> selectMemo(
      int tripId, BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final responses = await dio.get("$backUrl/memo/selectMemo/$tripId");
      print('responses memo! $responses.data');
      if (responses.statusCode == 200) {
        final List<dynamic> responseData = responses.data;
        final List<Map<String, dynamic>> result =
            responseData.map((item) => item as Map<String, dynamic>).toList();
        print('조회result $result');
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
