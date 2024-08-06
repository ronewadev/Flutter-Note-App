import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
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

  Color _getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('My Notes'),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
              onPressed: _toggleTheme,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Deleted Notes'),
                    content: deletedNotes.isEmpty
                        ? Text('No deleted notes.')
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: deletedNotes.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, String> note = entry.value;
                              return ListTile(
                                title: Text(note['title']!),
                                subtitle: Text(note['content']!),
                                trailing: IconButton(
                                  icon: Icon(Icons.restore),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _restoreNote(index);
                                  },
                                ),
                              );
                            }).toList(),
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
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
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
                        children: List.generate(notes.length, (index) {
                          return GestureDetector(
                            onTap: () => _addOrUpdateNote(index: index),
                            child: Card(
                              color: _getRandomColor(),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            notes[index]['title'] ?? '',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 8),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Text(
                                                _getFormattedContent(notes[index]['content']!),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => _deleteNote(index),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
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
