import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
 // accentColor: Colors.purple,
  cardColor: Colors.white,
  colorScheme: ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.purple,
    surface: Colors.white,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[850],
 // accentColor: Colors.purple,
  cardColor: Colors.grey[850],
  colorScheme: ColorScheme.dark(
    primary: Colors.purple,
    secondary: Colors.blue,
    surface: Color.fromARGB(0, 155, 39, 176),
  ),
);
