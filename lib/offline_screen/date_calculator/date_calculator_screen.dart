
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateCalculatorScreen extends StatefulWidget {
  const DateCalculatorScreen({super.key});

  @override
  State<DateCalculatorScreen> createState() => _DateCalculatorScreenState();
}

class _DateCalculatorScreenState extends State<DateCalculatorScreen> {
  DateTime _selectedDate = DateTime.now();
  int _daysToAdd = 0;
  DateTime? _resultDate;

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _calculateDate() {
    setState(() {
      _resultDate = _selectedDate.add(Duration(days: _daysToAdd));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Selected Date:', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: Text(
                    DateFormat.yMd().format(_selectedDate),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Days to add',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _daysToAdd = int.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _calculateDate,
                child: const Text('Calculate'),
              ),
            ),
            const SizedBox(height: 30),
            if (_resultDate != null)
              Center(
                child: Text(
                  'Result: ${DateFormat.yMd().format(_resultDate!)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
