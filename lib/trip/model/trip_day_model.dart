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
    print('요청 가나?');

    try {
      final responses =
          await dio.post("$backUrl/tripDay/saveTripDayLocation", data: data);
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
}
