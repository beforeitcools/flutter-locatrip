import 'package:dio/dio.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_locatrip/common/Auth/auth_dio_interceptor.dart';
import 'package:flutter_locatrip/common/model/local_area_auth_controller.dart';
import 'package:flutter_locatrip/common/widget/url.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdviceModel {
  Future<Map<String, dynamic>> checkUserLocalAreaAuthIsValid(
      BuildContext context) async {
    final dio = Dio();
    final LocalAreaAuthController _localAreaAuthController =
        LocalAreaAuthController();
    dio.interceptors.add(AuthInterceptor(dio, context));

    final FlutterSecureStorage storage = FlutterSecureStorage();
    final dynamic stringId = await storage.read(key: 'userId');
    final int userId = int.tryParse(stringId) ?? 0;

    try {
      final response = await dio.get("$backUrl/advice/UserLocalArea/$userId");

      // 유저의 현지인 인증이 유효한지 검사
      // 1. 인증 지역이 있는지 2. 인증유효기간 이내인지
      if (response.statusCode == 200) {
        Map<String, dynamic> _localAreaAuthData =
            response.data as Map<String, dynamic>;
        if (_localAreaAuthData['localArea'] != null) {
          if (_localAreaAuthController.calculateDaysLeftUntilExpiration(
                  _localAreaAuthData['localAreaAuthDate']) >
              0) {
            return {
              "isValid": true,
              "localArea": _localAreaAuthData['localArea']
            };
          } else {
            return {"isValid": false, "localArea": null};
          }
        } else {
          return {"isValid": false, "localArea": null};
        }
      } else {
        return {"isValid": false, "localArea": null};
      }
    } catch (e) {
      print(e);
      return {"isValid": false, "localArea": null};
      // throw Exception("Error: $e");
    }
  }

  Future<Map<String, dynamic>> getPostsData(
      BuildContext context, String localArea) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final response = await dio.get("$backUrl/advice/getPosts/$localArea");

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("post 데이터 로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<List<dynamic>> checkIfUserHasTrips(BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    final FlutterSecureStorage storage = FlutterSecureStorage();
    final dynamic stringId = await storage.read(key: 'userId');
    final int userId = int.tryParse(stringId) ?? 0;

    try {
      final response = await dio.get("$backUrl/advice/checkValidTrips/$userId");

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("데이터 로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<String> insertAdvice(
      BuildContext context, Map<String, Object> adviceData) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final response = await dio.post("$backUrl/advice/insertAdvice",
          data: adviceData,
          options: Options(headers: {"Content-Type": "application/json"}));

      if (response.statusCode == 200) {
        return response.data as String;
      } else {
        throw Exception("데이터 로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<Map<String, dynamic>> getAdviceData(
      BuildContext context, Map<String, Object> postIdAndLocattionIdDTO) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final response = await dio.get("$backUrl/advice/getAdvice",
          data: postIdAndLocattionIdDTO,
          options: Options(headers: {"Content-Type": "application/json"}));

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("데이터 로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }
}
