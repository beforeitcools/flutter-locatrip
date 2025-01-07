import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/Auth/auth_dio_interceptor.dart';
import 'package:flutter_locatrip/common/widget/url.dart';

class MypageModel {
  Future<Map<String, dynamic>> getMyPageData(BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final response = await dio.get("$backUrl/mypage/main");

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("마이페이지 데이터 로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }
}
