import 'package:flutter/material.dart';

import 'color.dart';

TextTheme appTextTheme() {
  return TextTheme(
    // Appbar Text
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    headlineSmall:
        TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: grayColor),
    // body 안의 title
    titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    // body fontSize
    bodyLarge: TextStyle(fontSize: 18),
    bodyMedium: TextStyle(fontSize: 16),
    bodySmall: TextStyle(fontSize: 14),
    // 버튼 등의 fontSize
    labelLarge: TextStyle(fontSize: 16),
    labelMedium: TextStyle(fontSize: 14),
    labelSmall: TextStyle(fontSize: 12),
  );
}
