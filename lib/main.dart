import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/Auth/screen/login_screen.dart';
import 'package:flutter_locatrip/Auth/screen/signup_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
    final storage = new FlutterSecureStorage();

    final accessToken = await storage.read(key: 'ACCESS_TOKEN');
    print(accessToken);

    if (accessToken == null) {
      return StartScreen();
    } else {
      return HomeScreen();
    }
  }
}
