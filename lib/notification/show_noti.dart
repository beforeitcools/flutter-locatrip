import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

showNotification(String? title, String? content) async{

  // 안드로이드 알림 설정
  var androidDetails = AndroidNotificationDetails(
    "test_id",
    "테스트 채널",
    priority: Priority.max,
    color: blackColor
  );

  //애플
  var iosDetails = DarwinNotificationDetails(
    presentAlert: true, // 알림 표시될 때 팝업 보여줄 지
    presentBadge: true, // 아이콘
    presentSound: true,
  );

  // notifications.show(1, title, content,
  //     NotificationDetails(android: androidDetails, iOS: iosDetails),
  //     payload: "test_payload");
}