import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../common/Auth/auth_dio_interceptor.dart';
import '../../common/widget/url.dart';

class MainModel {
  Future<Map<String, dynamic>> getHostUserInfo(
      BuildContext context, int hostId) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final responses = await dio.get("$backUrl/main/getUserInfo/$hostId");

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
