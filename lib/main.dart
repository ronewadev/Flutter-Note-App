import 'package:flutter/material.dart';
import 'package:my_app/Screens/loginScreen.dart';
import 'package:my_app/Screens/notesScreen.dart';
import 'package:my_app/Screens/registrationScreen.dart';
import 'package:my_app/util/theme.dart';

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
      home: NotesPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/notes': (context) => NotesPage(),
      },
    );
  }
}
