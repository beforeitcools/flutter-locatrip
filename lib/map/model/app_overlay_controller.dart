import 'package:flutter/material.dart';

class AppOverlayController {
  static OverlayEntry? overlayEntry;

  static void showAppBarOverlay(
      BuildContext context, String text, VoidCallback onClose) {
    removeOverlay();

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            elevation: 1.0,
            child: AppBar(
              title: Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontSize: 20),
              ),
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  onClose(); // 콜백 호출
                  removeOverlay();
                },
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  static void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }
}
