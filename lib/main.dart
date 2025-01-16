import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/Auth/model/auth_model.dart';
import 'package:flutter_locatrip/Auth/screen/login_screen.dart';
import 'package:flutter_locatrip/Auth/screen/signup_screen.dart';
import 'package:flutter_locatrip/auth/model/kakao_key_loader.dart';
import 'package:flutter_locatrip/notification/init_noti.dart';
import 'package:flutter_locatrip/notification/show_noti.dart';
import 'package:flutter_locatrip/trip/screen/trip_invite_screen.dart';
import 'package:flutter_locatrip/trip/screen/trip_view_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Auth/screen/start_screen.dart';
import 'common/screen/error_screen.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'common/model/navigation_observer.dart';
import 'common/screen/home_screen.dart';
import 'common/screen/splash_screen.dart';
import 'common/widget/style.dart' as style;

final AppOverlayObserver appOverlayObserver = AppOverlayObserver();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? kakaoNativeAppKey =
      await KakaoKeyLoader.getNativeAppKey('KAKAO_NATIVE_APP_KEY');
  KakaoSdk.init(nativeAppKey: '${kakaoNativeAppKey}');
  print('Kakao Native App Key: $kakaoNativeAppKey');

  String? url = await receiveKakaoScheme();
  print('!url $url');
  kakaoSchemeStream.listen((url) {
    // url에 커스텀 URL 스킴이 할당됩니다. 할당된 스킴의 활용 코드를 작성합니다.
    print('url $url');
  }, onError: (e) {
    // 에러 상황의 예외 처리 코드를 작성합니다.
    print('에러메시지 $e');
  });

  await Firebase.initializeApp();

  //푸시 알림 관리 위한 객체
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  //FCM 위한 함수 세팅
  Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print("Background Message : ${message.notification?.title}");
    showNotification(message.notification?.title, message.notification?.body);
  }

  //권한 설정
  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // 서버로 토큰을 전송하는 함수
  Future<void> sendTokenToServer(String token) async {
    final response = await http.post(
      Uri.parse("내 주소"),
      headers: {"Contents-Type": "application/json"},
      body: '{"token":"$token"}',
    );

    if (response.statusCode == 200) {
      print("토큰 전송 성공");
    } else {
      print("전송 실패");
    }
  }

  void _initFCM() {
    initNotification();
    requestNotificationPermission();

    //앱 실행 시 FCM 푸시 알림 토큰 가져오는 코드
    _firebaseMessaging.getToken().then((token) {
      print("*** FCM TOKEN: $token ***");

      //서버로 토큰 전송
      if (token != null) {
        sendTokenToServer(token);
      }
    });

    // 포그라운드 상태에서 알림 처리 위한 핸들러
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("foreground message: ${message.notification?.title}");
      showNotification(message.notification?.title, message.notification?.body);
    });

    // 알림 클릭해서 맵이 열릴 때 핸들러
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("알림 클릭해서 맵 열리는 상태: ${message.notification?.title}");
    });

    // 백그라운드 및 종료상태에서 알람 처리 위한 핸들러
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  _initFCM();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<Widget?> _initFuture = Init.instance.initialize();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return FutureBuilder(
      future: _initFuture,
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
                "/tripInvite": (context) => TripInviteScreen()
              },
              navigatorObservers: [appOverlayObserver],
            );
          }
        }
      },
    );
  }
}

class Init {
  Init._();
  static final instance = Init._();
  Future<Widget?>? _initFuture; // 다중 실행 방지를 위한 캐싱

  Future<Widget?> initialize() {
    if (_initFuture == null) {
      _initFuture = _initProcess();
    }
    return _initFuture!;
  }

  Future<Widget?> _initProcess() async {
    await Future.delayed(Duration(milliseconds: 1000));

    // 초기 로딩(access Token 유무에 따라서 시작화면 제어 StartScreen() / HomeScreen()
    // 처음 로딩시 shared_preference에 자동 로그인 옵션 상태 체크
    // 마지막 로그인시의 상태저장, 로그아웃시 자동 로그인 해제됨, 로그아웃 안하고 앱 종료시 자동 로그인 옵션 상태 유지

    final _storage = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();
    final autoLogin = await prefs.getBool('autoLogin') ?? false;
    final AuthModel _authModel = AuthModel();

    // 자동 로그인 on
    if (autoLogin) {
      final userId = await _storage.read(key: 'user_id');
      final password = await _storage.read(key: 'password');
      print('userid : $userId');
      print('password : $password');

      Map<String, dynamic> loginData = {
        'userId': userId,
        'password': password,
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
