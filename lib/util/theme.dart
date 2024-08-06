import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  visualDensity: VisualDensity.adaptivePlatformDensity,
   colorScheme: ColorScheme.light(
    primary: Colors.blue,
    onPrimary: Colors.white,
  ),
  textTheme: TextTheme(
   // headline2: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
   // bodyText1: TextStyle(color: Colors.black),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textTheme: TextTheme(
    //headline2: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
   // bodyText1: TextStyle(color: Colors.white),
  ),
);


