import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../common/Auth/auth_dio_interceptor.dart';
import '../../common/widget/url.dart';

class TripUserModel {
  Future<Map<String, dynamic>> saveTripUser(
      BuildContext context, Map<String, dynamic> data) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final responses = await dio.post("$backUrl/tripUser/saveTripUser",
          data: jsonEncode(data));

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

  Future<bool> isExistTripUser(
      BuildContext context, Map<String, dynamic> data) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final responses = await dio.get("$backUrl/tripUser/isExistTripUser",
          data: jsonEncode(data));

      if (responses.statusCode == 200) {
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
