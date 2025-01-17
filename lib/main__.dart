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

  /// The route configuration.
  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          // 자동 로그인 여부에 따라 초기 화면 설정
          final autoLogin = state.extra as bool? ?? false;
          return autoLogin ? HomeScreen() : StartScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (BuildContext context, GoRouterState state) =>
                HomeScreen(),
          ),
          GoRoute(
            path: '/start',
            builder: (BuildContext context, GoRouterState state) =>
                StartScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (BuildContext context, GoRouterState state) =>
                LoginScreen(),
          ),
          GoRoute(
            path: '/signup',
            builder: (BuildContext context, GoRouterState state) =>
                SignupScreen(),
          ),
          /*  GoRoute(
            path: '/tripInvite',
            builder: (BuildContext context, GoRouterState state) {
              final tripId = state.uri.queryParameters['tripId'];
              print('Received tripId: $tripId'); // 디버깅용 로그
              if (tripId == null) {
                return ErrorScreen();
              }
              // return TripInviteScreen(tripId: tripId);
            },
          ),*/
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return FutureBuilder<bool>(
      future: _initFuture.then((screen) => screen is HomeScreen),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(home: SplashScreen());
        } else if (snapshot.hasError) {
          return MaterialApp(home: ErrorScreen());
        } else {
          final isAutoLogin = snapshot.data ?? false;
          Init.instance.isAutoLogin = isAutoLogin; // 로그인 상태 저장
          return MaterialApp.router(
            routerConfig: _router,
            theme: style.theme,
            debugShowCheckedModeBanner: false,
          );
        }
      },
    );
  }
}

class Init {
  Init._();
  static final instance = Init._();
  Future<Widget?>? _initFuture; // 다중 실행 방지를 위한 캐싱
  bool isAutoLogin = false;

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
        isAutoLogin = true;
        // 자동 로그인 성공
        return HomeScreen();
      } catch (e) {
        print(e);
        isAutoLogin = false;
        // 자동 로그인 실패
        return StartScreen();
      }
    }
    // 자동 로그인 off
    else {
      isAutoLogin = false;
      return StartScreen();
    }
  }
}
