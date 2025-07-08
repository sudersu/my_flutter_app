import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class AddTaskDialog extends StatefulWidget {
  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _hasReminder = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final DateTime taskDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final task = Task(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dateTime: taskDateTime,
      hasReminder: _hasReminder,
    );

    final box = Hive.box<Task>('tasks');
    await box.add(task);

    if (_hasReminder) {
      final notificationService = NotificationService();
      await notificationService.scheduleNotification(task);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Task',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter task title',
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter task description',
              ),
              style: TextStyle(color: Colors.white),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF334155),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF334155),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.white70, size: 20),
                          SizedBox(width: 8),
                          Text(
                            _selectedTime.format(context),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _hasReminder,
                  onChanged: (value) {
                    setState(() {
                      _hasReminder = value ?? false;
                    });
                  },
                  activeColor: Color(0xFF3B82F6),
                ),
                Text(
                  'Set reminder with voice alert',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveTask,
                  child: Text('Add Task'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

