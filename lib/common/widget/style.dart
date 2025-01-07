import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/common/widget/text.dart';

Map<int, Color> _pointBlueSwatch = {
  50: pointBlueColor.withOpacity(0.1),
  100: pointBlueColor.withOpacity(0.2),
  200: pointBlueColor.withOpacity(0.3),
  300: pointBlueColor.withOpacity(0.4),
  400: pointBlueColor.withOpacity(0.5),
  500: pointBlueColor,
  600: pointBlueColor.withOpacity(0.7),
  700: pointBlueColor.withOpacity(0.8),
  800: pointBlueColor.withOpacity(0.9),
  900: pointBlueColor.withOpacity(1),
};

MaterialColor pointBlueMaterialColor =
    MaterialColor(pointBlueColor.value, _pointBlueSwatch);

var theme = ThemeData(
  primarySwatch: pointBlueMaterialColor,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: pointBlueMaterialColor,
  ),
  dialogBackgroundColor: Colors.white,
  primaryColor: pointBlueColor,
  fontFamily: 'NotoSansKR',
  appBarTheme:
      AppBarTheme(backgroundColor: Colors.white, foregroundColor: blackColor),
  scaffoldBackgroundColor: Colors.white,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: blackColor,
    unselectedItemColor: grayColor,
    selectedLabelStyle: TextStyle(fontSize: 12),
    // elevation: 8.0
  ),
  textTheme: appTextTheme(),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: pointBlueColor,
    foregroundColor: Colors.white,
  ),
);
