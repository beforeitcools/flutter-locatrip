import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/Auth/model/auth_model.dart';
import 'package:flutter_locatrip/Auth/screen/login_screen.dart';
import 'package:flutter_locatrip/Auth/screen/signup_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Auth/screen/start_screen.dart';
import 'common/screen/error_screen.dart';
import 'common/screen/home_screen.dart';
import 'common/screen/splash_screen.dart';
import 'common/widget/style.dart' as style;

void main() {
  runApp(/*const*/ MyApp());
}

class MyApp extends StatelessWidget {
  /*const MyApp({super.key});*/

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Init.instance.initialize(context),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(home: SplashScreen());
          } else if (snapshot.hasError) {
            return MaterialApp(home: ErrorScreen());
          } else {
            {
              return MaterialApp(
                theme: style.theme,
                debugShowCheckedModeBanner: false,
                home: snapshot.data, // 로딩 완료시 HomeScreen()
                routes: {
                  "/home": (context) => HomeScreen(),
                  "/start": (context) => StartScreen(),
                  "/login": (context) => LoginScreen(),
                  "/signup": (context) => SignupScreen(),
                },
              );
            }
          }
        });
  }

  /*@override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: style.theme,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      routes: {
        "/home": (context) => HomeScreen(),
      },
    );
  }*/
}

class Init {
  Init._();
  static final instance = Init._();

  Future<Widget?> initialize(BuildContext context) async {
    await Future.delayed(Duration(milliseconds: 1000));

    // 초기 로딩(access Token 유무에 따라서 시작화면 제어 StartScreen() / HomeScreen()
    // 처음 로딩시 shared_preference에 자동 로그인 옵션 상태 체크
    // 마지막 로그인시의 상태저장, 로그아웃시 자동 로그인 해제됨, 로그아웃 안하고 앱 종료시 자동 로그인 옵션 상태 유지

    final _storage = new FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();
    final autoLogin = await prefs.getBool('autoLogin') ?? false;
    final AuthModel _authModel = new AuthModel();

    // 자동 로그인 on
    if (autoLogin) {
      Map<String, dynamic> loginData = {
        'userId': _storage.read(key: 'user_id'),
        'password': _storage.read(key: 'password'),
      };

      try {
        await _authModel.login(loginData);
        // 자동 로그인 성공
        return HomeScreen();
      } catch (e) {
        print(e);
        // 자동 로그인 실패
        return StartScreen();
      }
    }
    // 자동 로그인 off
    else {
      return StartScreen();
    }
  }
}
