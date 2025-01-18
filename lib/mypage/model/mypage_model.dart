import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/Auth/auth_dio_interceptor.dart';
import 'package:flutter_locatrip/common/model/create_dio.dart';
import 'package:flutter_locatrip/common/widget/url.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MypageModel {
  Future<Map<String, dynamic>> getMyPageData(BuildContext context) async {
    final SDio sdio = SDio();
    final Dio dio = await sdio.createDio();
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

  Future<String> updateProfile(Map<String, String> updatedData, File? image,
      BuildContext context) async {
    final SDio sdio = SDio();
    final Dio dio = await sdio.createDio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      FormData formData = FormData.fromMap({
        'updatedData': jsonEncode(updatedData),
        'profileImg': image == null
            ? null
            : await MultipartFile.fromFile(
                image.path,
                filename: image.path.split('/').last,
              ),
      });

      final response = await dio.post("$backUrl/mypage/updateProfile",
          data: formData,
          options: Options(
              headers: {'Content-Type': 'multipart/form-data; charset=UTF-8'}));

      if (response.statusCode == 200) {
        return "프로필 수정 완료";
      } else {
        return "프로필 수정 실패";
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<Map<String, dynamic>> getMyTripData(BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final response = await dio.get("$backUrl/mypage/myTrip");

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("내 여행 데이터 로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<String> deleteTrip(BuildContext context, int tripId) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final response = await dio.post("$backUrl/mypage/deleteTrip/$tripId");

      if (response.statusCode == 200) {
        return "여행 삭제 성공";
      } else {
        return "여행 삭제 실패";
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<List<dynamic>> getMypostData(BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    final FlutterSecureStorage storage = FlutterSecureStorage();
    final dynamic stringId = await storage.read(key: 'userId');
    final int userId = int.tryParse(stringId) ?? 0;

    try {
      final response = await dio.get("$backUrl/mypage/myPost/$userId");

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("내 포스트 데이터 로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<List<dynamic>> getMyAdviceData(BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    final FlutterSecureStorage storage = FlutterSecureStorage();
    final dynamic stringId = await storage.read(key: 'userId');
    final int userId = int.tryParse(stringId) ?? 0;

    try {
      final response = await dio.get("$backUrl/mypage/myAdvice/$userId");

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("내 첨삭 데이터 로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<Map<String, dynamic>> getMyFavoriteData(BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    final FlutterSecureStorage storage = FlutterSecureStorage();
    final dynamic stringId = await storage.read(key: 'userId');
    final int userId = int.tryParse(stringId) ?? 0;

    try {
      final response = await dio.get("$backUrl/mypage/myFavorite/$userId");

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("내 저장 데이터 로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<dynamic> insertFavoritePost(BuildContext context, int postId) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    final FlutterSecureStorage storage = FlutterSecureStorage();
    final dynamic stringId = await storage.read(key: 'userId');
    final int userId = int.tryParse(stringId) ?? 0;
    Map<String, dynamic> favoritePostData = {
      "postId": postId,
      "userId": userId,
    };

    try {
      final responses = await dio.post("$backUrl/mypage/insertFavoritePost",
          data: favoritePostData);
      if (responses.statusCode == 200) {
        return responses.data as Map<String, dynamic>;
      } else {
        return "장소 좋아요 저장에 실패했습니다. ${responses.data['message']}";
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }

  Future<String> deleteFavoritePost(BuildContext context, int postId) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    final FlutterSecureStorage storage = FlutterSecureStorage();
    final dynamic stringId = await storage.read(key: 'userId');
    final int userId = int.tryParse(stringId) ?? 0;
    Map<String, dynamic> favoritePostData = {
      "postId": postId,
      "userId": userId,
    };

    try {
      final response = await dio.post("$backUrl/mypage/deleteFavoritePost",
          data: favoritePostData);
      if (response.statusCode == 200) {
        return response.data['message'];
      } else {
        return "장소 좋아요 삭제에 실패했습니다. ${response.data['message']}";
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }

  Future<Map<String, dynamic>> getMyLocalAreaAuthData(
      BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    final FlutterSecureStorage storage = FlutterSecureStorage();
    final dynamic stringId = await storage.read(key: 'userId');
    final int userId = int.tryParse(stringId) ?? 0;

    try {
      final response = await dio.get("$backUrl/mypage/myLocalArea/$userId");

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("내 현지인 인증 데이터 로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<Map<String, dynamic>> updateLocalAreaAuthentication(
      BuildContext context, String region) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    final FlutterSecureStorage storage = FlutterSecureStorage();
    final dynamic stringId = await storage.read(key: 'userId');
    final int userId = int.tryParse(stringId) ?? 0;
    Map<String, dynamic> localAreaAuthData = {
      "localArea": region,
      "id": userId,
    };

    try {
      final response = await dio.post("$backUrl/mypage/updateMyLocalArea",
          data: localAreaAuthData);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("내 현지인 인증 업데이트 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<Map<String, dynamic>> getUserPageData(
      BuildContext context, int userId) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final response = await dio.get("$backUrl/mypage/userpage/$userId");

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("유저페이지 데이터 로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<List<dynamic>> getMyAlarmData(BuildContext context) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    final FlutterSecureStorage storage = FlutterSecureStorage();
    final dynamic stringId = await storage.read(key: 'userId');
    final int userId = int.tryParse(stringId) ?? 0;

    try {
      final response = await dio.get("$backUrl/mypage/alarm/$userId");

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("알림 데이터 로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }
}
