import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/url.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthModel {
  Future<String> checkUserId(String userId) async {
    final dio = Dio();

    try {
      final response =
          await dio.get("$backUrl/auth/checkUserId?userId=$userId");

      if (response.statusCode == 200) {
        return response.data['message'];
      } else {
        throw Exception("이메일 중복체크 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<String> checkNickname(String nickname) async {
    final dio = Dio();

    try {
      final response =
          await dio.get("$backUrl/auth/checkNickname?nickname=$nickname");

      if (response.statusCode == 200) {
        return response.data['message'];
      } else {
        throw Exception("닉네임 중복체크 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<String> signup(Map<String, String> signupData, File? image) async {
    final dio = Dio();

    try {
      FormData formData = FormData.fromMap({
        'signupData': jsonEncode(signupData),
        'profileImg': image == null
            ? null
            : await MultipartFile.fromFile(
                image.path,
                filename: image.path.split('/').last,
              ),
      });
      print(formData);
      print(formData.fields);
      final response = await dio.post("$backUrl/auth/signup",
          data: formData,
          options: Options(
              headers: {'Content-Type': 'multipart/form-data; charset=UTF-8'}));

      if (response.statusCode == 200) {
        return "회원 가입 완료";
      } else {
        return "회원 가입 실패";
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<String> login(Map<String, dynamic> loginData) async {
    final dio = Dio();

    try {
      final response = await dio.post("$backUrl/auth/login", data: loginData);

      // 로그인 성공시 Access 토큰, Refresh 토큰 스토리지에 추가
      if (response.statusCode == 200) {
        final FlutterSecureStorage _storage = FlutterSecureStorage();
        final accessToken = response.headers['Authorization']?.first;
        final refreshToken = response.headers['Refresh_Token']?.first;
        await _storage.write(key: 'ACCESS_TOKEN', value: accessToken);
        await _storage.write(key: 'REFRESH_TOKEN', value: refreshToken);

        return "로그인 완료";
      } else {
        return "로그인 실패";
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // 로그인 실패 타입 관리
        if (e.response?.statusCode == 401) {
          throw Exception(e.response?.data['failType'] ?? "인증 실패");
        } else if (e.response?.statusCode == 404) {
          throw Exception(e.response?.data['failType'] ?? "사용자 없음");
        } else if (e.response?.statusCode == 403) {
          throw Exception(e.response?.data['failType'] ?? "접근 금지");
        }
      }
      throw Exception("Error: $e");
    }
  }

  Future<String> logout() async {
    final dio = Dio();
    final FlutterSecureStorage _storage = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();

    final refreshToken = await _storage.read(key: 'REFRESH_TOKEN');
    // 백서버에 refresh 토큰 db에서 delete 요청
    try {
      print(refreshToken);
      final response = await dio.post(
        '$backUrl/auth/logout',
        options: Options(headers: {'Refresh_Token': refreshToken}),
      );

      // storage 모두 제거, 자동로그인 off
      await _storage.deleteAll();
      await prefs.setBool('autoLogin', false);

      if (response.statusCode == 200) {
        print(response.data);
        return response.data['message'];
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data['message'] ?? '알 수 없는 오류 발생';
        await _storage.deleteAll();
        await prefs.setBool('autoLogin', false);
        print("Error: $errorMessage");
        return errorMessage;
      } else {
        throw Exception("네트워크 오류 발생");
      }
    }
  }
}
