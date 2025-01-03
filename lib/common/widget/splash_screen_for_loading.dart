import 'package:flutter/material.dart';

class LoadingOverlay {
  static final _overlay = GlobalKey<NavigatorState>();

  static void show() {
    _overlay.currentState?.overlay?.insert(
      OverlayEntry(
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
              )),
    );
  }

  static void hide() {
    _overlay.currentState?.overlay?.dispose();
  }
}
