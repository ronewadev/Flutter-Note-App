import 'package:flutter/material.dart';
import 'package:my_app/Screens/Auth/LoginScreen.dart';
import 'package:my_app/Screens/NotesScreen/NotesScreen.dart';
import 'package:my_app/Screens/Auth/RegistrationScreen.dart';
import 'package:my_app/Screens/util/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Note App',
      theme: lightTheme, 
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: RegistrationPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/notes': (context) => NotesPage(),
      },
    );
  }
}
