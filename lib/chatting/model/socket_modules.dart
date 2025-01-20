import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/Auth/auth_dio_interceptor.dart';
import 'package:flutter_locatrip/common/model/create_dio.dart';
import 'package:flutter_locatrip/common/widget/url.dart';

class SocketModules {
  // 현재 상태 가져오는 함수 bool
  Future<dynamic> getEditingState(int tripId, BuildContext context) async {
    final SDio sdio = SDio();
    final Dio dio = await sdio.createDio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final response = await dio
          .get("$backUrl/edit/getState", queryParameters: {"tripId": tripId});
      final data = response.data;
      return data as bool;
    } catch (e) {
      print("상태 가져오기 실패 ");
      throw Exception("Error $e");
    }
  }

  Future<void> changeEditingState(
      int tripId, bool state, BuildContext context) async {
    final SDio sdio = SDio();
    final Dio dio = await sdio.createDio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    print('changeEditingState 들어갔어?');
    try {
      final response = await dio.post("$backUrl/edit/updateState",
          queryParameters: {"tripId": tripId, "state": state});
    } catch (e) {
      print("편집 상태 업데이트 실패");
      throw Exception("Error $e");
    }
  }
}
