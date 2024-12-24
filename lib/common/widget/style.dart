import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/common/widget/text.dart';

var theme = ThemeData(
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
);
