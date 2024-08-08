import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class NotesFunctions {
  Future<String?> loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<List<Map<String, String>>> loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('notes') ?? []).map((note) {
      List<String> splitNote = note.split('||');
      return {'title': splitNote[0], 'content': splitNote[1]};
    }).toList();
  }

  Future<List<Map<String, String>>> loadDeletedNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('deletedNotes') ?? []).map((note) {
      List<String> splitNote = note.split('||');
      return {'title': splitNote[0], 'content': splitNote[1]};
    }).toList();
  }

  Future<void> saveNotes(List<Map<String, String>> notes, List<Map<String, String>> deletedNotes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'notes',
      notes.map((note) => '${note['title']}||${note['content']}').toList(),
    );
    prefs.setStringList(
      'deletedNotes',
      deletedNotes.map((note) => '${note['title']}||${note['content']}').toList(),
    );
  }

  Future<bool> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> saveTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  LinearGradient getRandomGradientColor() {
    final random = Random();
    Color color1 = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    Color color2 = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    return LinearGradient(
      colors: [color1, color2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  String getFormattedContent(String content) {
    if (content.length <= 150) {
      return content;
    } else {
      return content.substring(0, 150) + '...';
    }
  }
}
