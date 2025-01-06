import 'package:flutter/material.dart';
import 'common/model/navigation_observer.dart';
import 'common/screen/home_screen.dart';
import 'common/widget/style.dart' as style;

final AppOverlayObserver appOverlayObserver = AppOverlayObserver();
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: style.theme,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      routes: {
        "/home": (context) => HomeScreen(),
      },
      navigatorObservers: [appOverlayObserver],
    );
  }
}
