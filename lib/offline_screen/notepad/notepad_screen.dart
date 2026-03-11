
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotepadScreen extends StatefulWidget {
  const NotepadScreen({super.key});

  @override
  State<NotepadScreen> createState() => _NotepadScreenState();
}

class _NotepadScreenState extends State<NotepadScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    final note = prefs.getString('note') ?? '';
    _textController.text = note;
  }

  Future<void> _saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('note', _textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Notepad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveNote();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note saved!')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textController,
          maxLines: null, // Allow unlimited lines
          expands: true, // Make the text field fill the screen
          decoration: const InputDecoration(
            hintText: 'Write your notes here...',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
