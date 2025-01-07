import 'package:flutter/material.dart';

class AppOverlayObserver extends NavigatorObserver {
  OverlayEntry? overlayEntry;

  void setOverlayEntry(OverlayEntry entry) {
    overlayEntry = entry;
  }

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    removeOverlay(); // 새로운 페이지로 이동할 때 오버레이 제거
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    removeOverlay(); // 페이지에서 뒤로 가기 할 때 오버레이 제거
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    removeOverlay(); // 라우트가 제거될 때 오버레이 제거
    super.didRemove(route, previousRoute);
  }
}

// 전역 Observer 객체
final AppOverlayObserver appOverlayObserver = AppOverlayObserver();
