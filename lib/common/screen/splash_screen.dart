import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
