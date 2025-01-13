import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

initNotification() async{
  // 안드로이드 초기화 설정
  var androidInitialization = AndroidInitializationSettings("locat_app_icon");
  // ios 설정
  var iosSetting = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  var initializationSettings =
  InitializationSettings(android: androidInitialization, iOS: iosSetting);

  // 초기화 실행
  await notifications.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print("알림이 클릭됨 : ${response.payload}");
    },
  );

  // Android 알림 채널 생성
  var androidChannel = AndroidNotificationChannel(
    "test_id", // 채널 id 중복되면 안됨
    "테스트채널", // 채널 이름
    description: "알림에 대한 설명",
    importance: Importance.max, // 알림의 중요도 설정
    playSound: true, // 소리설정
    enableVibration: true, // 진동 설정
    vibrationPattern: Int64List.fromList([0, 1000]), //진동 패턴
  );

  // 채널 등록
  try {
    await notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    print("테스트 채널 생성 완료");
  } catch (e) {
    print("테스트 채널 생성 오류 :$e");
  }
}