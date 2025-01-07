import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/Auth/model/auth_model.dart';
import 'package:flutter_locatrip/common/widget/url.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final BuildContext context;
  final AuthModel _authModel = AuthModel();

  AuthInterceptor(this._dio, this.context);

  void _navigateToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await _storage.read(key: 'ACCESS_TOKEN');
    print("accessToken: $accessToken");

    // header에 access 토큰 추가
    // 스토리지에 access 토큰 없으면 login Screen 으로~
    if (accessToken != null) {
      options.headers['Authorization'] = accessToken;
      handler.next(options);
    } else {
      _navigateToLogin();
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    /*Back Server에서 access 토큰 만료이면 401 Unauthorized
    refresh 토큰 header에 담아서 access 토큰 재발급 요청
    재발급된 access 토큰 storage에 담아주고 원래 요청의 header에 재발급된 access 토큰 추가해서 다시 요청*/
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.read(key: 'REFRESH_TOKEN');
      print("여기는~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
      print("스토리지에 있던 RT: $refreshToken");

      if (refreshToken != null) {
        // refresh 토큰 header에 담아서 access 토큰 재발급 요청
        print("오긴 하잖아???");
        final refreshResponse = await _dio.post(
          "$backUrl/auth/refreshAccessToken",
          options: Options(headers: {'Refresh_Token': refreshToken}),
        );

        if (refreshResponse.statusCode == 200) {
          // final newAccessToken = refreshResponse.data['accessToken'];
          final newAccessToken =
              refreshResponse.headers['Authorization']?.first;
          print("새로 받은 AT : $newAccessToken");
          // 재발급된 access 토큰 storage에 담아주기
          await _storage.write(key: 'ACCESS_TOKEN', value: newAccessToken);

          // 원래 요청의 header에 재발급된 access 토큰 추가해서 다시 요청
          err.requestOptions.headers['Authorization'] = newAccessToken;

          final retryResponse = await _dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        } else {
          print("제발 이리아줘");
          // 요청 실패(refresh 토큰 만료/ 요청에 보낸 refresh 토큰과 서버 DB의 refresh 토큰이 일치 하지 않는 경우 등)
          await _storage.deleteAll();
          await prefs.setBool('autoLogin', false);
          _navigateToLogin();
          handler.reject(err);
        }
      } else {
        // refresh 토큰이 없다면
        await _storage.deleteAll();
        await prefs.setBool('autoLogin', false);
        _navigateToLogin();
        handler.reject(err);
      }
    }
    // access 토큰 서명 오류 또는 파싱 오류(잘못된 접근)
    else if (err.response?.statusCode == 403) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("토큰 만료!")));
      await _storage.deleteAll();
      await prefs.setBool('autoLogin', false);
      _navigateToLogin();
    } else {
      await _storage.deleteAll();
      await prefs.setBool('autoLogin', false);
      _navigateToLogin();
    }
  }
}
