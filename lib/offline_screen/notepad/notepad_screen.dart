
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class NotepadScreen extends StatefulWidget {
  const NotepadScreen({super.key});

  @override
  State<NotepadScreen> createState() => _NotepadScreenState();
}

class _NotepadScreenState extends State<NotepadScreen> {
  final TextEditingController _textController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<String> _base64Images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ar', null);
    _loadNote();
  }

  Future<void> _loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = 'note_${_selectedDate.toIso8601String().split('T')[0]}';
    final noteData = prefs.getString(dateKey);
    
    if (noteData != null) {
      if (noteData.startsWith('{')) {
        try {
          final Map<String, dynamic> data = jsonDecode(noteData);
          _textController.text = data['text'] ?? '';
          _base64Images = List<String>.from(data['images'] ?? []);
        } catch (e) {
          _textController.text = noteData;
          _base64Images = [];
        }
      } else {
        _textController.text = noteData;
        _base64Images = [];
      }
    } else {
      _textController.text = '';
      _base64Images = [];
    }
    setState(() {});
  }

  Future<void> _saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = 'note_${_selectedDate.toIso8601String().split('T')[0]}';
    
    final Map<String, dynamic> data = {
      'text': _textController.text,
      'images': _base64Images,
    };
    await prefs.setString(dateKey, jsonEncode(data));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الحفظ بنجاح!'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadNote();
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      setState(() {
        _base64Images.add(base64String);
      });
      _saveNote(); // Auto save when image is added
    }
  }

  void _removeImage(int index) {
    setState(() {
      _base64Images.removeAt(index);
    });
    _saveNote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'المذكرة اليومية',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _pickDate,
                    tooltip: 'تحديد التاريخ',
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _pickImage,
                    tooltip: 'إضافة صورة',
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _saveNote,
                    tooltip: 'حفظ',
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    DateFormat('EEEE, d MMMM y', 'ar').format(_selectedDate),
                    style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    TextField(
                      controller: _textController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'اكتب مذكرات اليوم هنا...',
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_base64Images.isNotEmpty)
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: List.generate(_base64Images.length, (index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.memory(
                                  base64Decode(_base64Images[index]),
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
