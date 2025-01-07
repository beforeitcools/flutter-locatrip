import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../common/Auth/auth_dio_interceptor.dart';
import '../../common/widget/url.dart';

class LocationModel {
  Future<dynamic> insertLocation(
      Map<String, dynamic> place, BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final responses = await dio.post("$backUrl/location/insert", data: place);
      if (responses.statusCode == 200) {
        return responses.data as Map<String, dynamic>;
      } else {
        return "장소 저장에 실패했습니다.";
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }

  Future<String> deleteFavorite(
      Map<String, dynamic> place, BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final responses =
          await dio.post("$backUrl/location/deleteFavorite", data: place);
      if (responses.statusCode == 200) {
        return responses.data as String;
      } else {
        return "내 장소 삭제에 실패했습니다.";
      }
    } catch (e) {
      throw Exception("Error : $e");
    }
  }

  Future<List<Map<String, bool>>?> fetchFavoriteStatusFromServer(
      List<String> locationNameList, BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.get("$backUrl/location/favorites",
          data: jsonEncode(locationNameList));
      if (response.statusCode == 200) {
        List<dynamic> rawData = response.data as List<dynamic>;

        // 데이터를 Map<String, bool>로 변환
        List<Map<String, bool>> result = rawData.map((item) {
          return Map<String, bool>.from(item as Map<String, dynamic>);
        }).toList();

        return result;
      }
    } catch (e) {
      print('Error fetching favorites: $e');
    }
  }
}
