import 'package:flutter/material.dart';

class MainScreenProvider extends ChangeNotifier {
  bool _shouldReload = false;

  bool get shouldReload => _shouldReload;

  // 상태를 업데이트하고 알림을 보냄
  void triggerReload() {
    _shouldReload = true;
    notifyListeners();
  }

  // 상태 초기화
  void resetReload() {
    _shouldReload = false;
  }
}
