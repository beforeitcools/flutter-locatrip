import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class AuthModel {
  String backUrl = "http://112.221.66.174:1102";

  Future<String> checkUserId(String userId) async {
    final dio = Dio();

    try {
      final response = await dio.get("$backUrl/checkUserId?userId=$userId");

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
          await dio.get("$backUrl/checkNickname?nickname=$nickname");

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
      final response = await dio.post("$backUrl/signup",
          data: formData,
          options: Options(headers: {'Content-Type': 'multipart/form-data'}));

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
}
