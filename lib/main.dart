import 'package:flutter/material.dart';
import 'common/screen/home_screen.dart';
import 'common/widget/style.dart' as style;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: style.theme,
      home: HomeScreen(),
      routes: {
        "/home": (context) => HomeScreen(),
      },
    );
  }
}
