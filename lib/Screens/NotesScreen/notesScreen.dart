import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with TickerProviderStateMixin {
  String? username;
  List<Map<String, String>> notes = [];
  List<Map<String, String>> deletedNotes = [];
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadNotes();
    _loadTheme();
  }

  _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
  }

  _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notes = (prefs.getStringList('notes') ?? []).map((note) {
        List<String> splitNote = note.split('||');
        return {'title': splitNote[0], 'content': splitNote[1]};
      }).toList();
      deletedNotes = (prefs.getStringList('deletedNotes') ?? []).map((note) {
        List<String> splitNote = note.split('||');
        return {'title': splitNote[0], 'content': splitNote[1]};
      }).toList();
    });
  }

  _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'notes', notes.map((note) => '${note['title']}||${note['content']}').toList());
    prefs.setStringList('deletedNotes',
        deletedNotes.map((note) => '${note['title']}||${note['content']}').toList());
  }

  _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  _saveTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      _saveTheme(isDarkMode);
    });
  }

  _addOrUpdateNote({int? index}) async {
    String newTitle = index == null ? '' : notes[index]['title']!;
    String newContent = index == null ? '' : notes[index]['content']!;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(hintText: 'Title'),
                  controller: TextEditingController(text: newTitle),
                  onChanged: (value) {
                    newTitle = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(hintText: 'Add note here'),
                  controller: TextEditingController(text: newContent),
                  onChanged: (value) {
                    newContent = value;
                  },
                  maxLines: 5,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (newTitle.isNotEmpty && newContent.isNotEmpty) {
                          setState(() {
                            if (index == null) {
                              notes.add({'title': newTitle, 'content': newContent});
                            } else {
                              notes[index] = {'title': newTitle, 'content': newContent};
                            }
                            _saveNotes();
                          });
                        }
                      },
                      child: Text(index == null ? 'Add' : 'Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _viewNoteInDetail(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notes[index]['title'] ?? ''),
          content: SingleChildScrollView(
            child: Text(notes[index]['content'] ?? ''),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.pop(context);
                _addOrUpdateNote(index: index);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                Navigator.pop(context);
                _deleteNote(index);
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  _deleteNote(int index) {
    setState(() {
      deletedNotes.add(notes[index]);
      notes.removeAt(index);
      _saveNotes();
    });
  }

  _restoreNote(int index) {
    setState(() {
      notes.add(deletedNotes[index]);
      deletedNotes.removeAt(index);
      _saveNotes();
    });
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  LinearGradient _getRandomGradientColor() {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hyperion Note'),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
              onPressed: _toggleTheme,
            ),
            IconButton(
              icon: Icon(Icons.delete_forever_rounded),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Deleted Notes'),
                    content: deletedNotes.isEmpty
                        ? Text('No deleted notes.')
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: deletedNotes.asMap().entries.map((entry) {
                                int index = entry.key;
                                Map<String, String> note = entry.value;
                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    title: Text(note['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                      _getFormattedContent(note['content']!),
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.restore),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _restoreNote(index);
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: _logout,
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (username != null)
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'My Notes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Hi, '),
                  Text(
                    '$username',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(', enjoy your notes ;).'),
                ],
              ),
              SizedBox(height: 20),
              notes.isEmpty
                  ? Expanded(child: Center(child: Text('Please add notes.')))
                  : Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: List.generate(notes.length, (index) {
                          return GestureDetector(
                            onTap: () => _viewNoteInDetail(index),
                            child: Card(
                              elevation: 4,
                              margin: EdgeInsets.all(4.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: isDarkMode ? Colors.grey[850] : Colors.white,
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _getRandomGradientColor().colors[0],
                                    width: 5,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: Offset(4, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        notes[index]['title'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          _getFormattedContent(notes[index]['content']!),
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit_rounded, size: 20).animate().rotate(),
                                            onPressed: () => _addOrUpdateNote(index: index),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete_rounded, size: 20).animate().shake(),
                                            onPressed: () => _deleteNote(index),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn();
                        }),
                      ),
                    ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addOrUpdateNote(),
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  String _getFormattedContent(String content) {
    if (content.length <= 150) {
      return content;
    } else {
      return content.substring(0, 150) + '...';
    }
  }
}
