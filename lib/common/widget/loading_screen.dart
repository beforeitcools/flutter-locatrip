import 'package:flutter/material.dart';

class LoadingOverlay {
  // static final _overlay = GlobalKey<NavigatorState>();
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayEntry = OverlayEntry(
        builder: (context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  width: 200,
                  height: 200,
                  image: AssetImage('assets/splash_screen_image.gif'),
                )
              ],
            ),
          ),
        ),
      );
      Overlay.of(context)?.insert(_overlayEntry!);
    });
  }

  static void hide() {
    // _overlay.currentState?.overlay?.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
