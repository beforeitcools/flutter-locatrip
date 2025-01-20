import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../common/Auth/auth_dio_interceptor.dart';
import '../../common/widget/url.dart';

class AdviceModel2 {
  Future<Map<String, dynamic>> selectAdviceList(
      BuildContext context, postId, userId) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final response = await dio.get("$backUrl/advice/selectAdviceList",
          queryParameters: {"postId": postId, "userId": userId});

      if (response.statusCode == 200) {
        print('responses${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }
}
