import 'package:flutter/material.dart';

import 'color.dart';

TextTheme appTextTheme() {
  return TextTheme(
    // Appbar Text
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      fontFamily: 'NotoSansKR',
    ),
    headlineMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'NotoSansKR',
    ),
    headlineSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: grayColor,
      fontFamily: 'NotoSansKR',
    ),
    // body 안의 title
    titleLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      fontFamily: 'NotoSansKR',
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: 'NotoSansKR',
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'NotoSansKR',
    ),
    // body fontSize
    bodyLarge: TextStyle(
      fontSize: 18,
      fontFamily: 'NotoSansKR',
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontFamily: 'NotoSansKR',
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontFamily: 'NotoSansKR',
    ),
    // 버튼 등의 fontSize
    labelLarge: TextStyle(
      fontSize: 16,
      fontFamily: 'NotoSansKR',
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontFamily: 'NotoSansKR',
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontFamily: 'NotoSansKR',
    ),
  );
}
