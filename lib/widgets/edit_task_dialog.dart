import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class EditTaskDialog extends StatefulWidget {
  final Task task;

  const EditTaskDialog({Key? key, required this.task}) : super(key: key);

  @override
  _EditTaskDialogState createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _hasReminder;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _selectedDate = widget.task.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.task.dateTime);
    _hasReminder = widget.task.hasReminder;
  }

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
      0, // seconds
      0, // milliseconds
    );

    print('Editing task - Original: ${widget.task.title} at ${widget.task.dateTime}');
    print('Editing task - New: ${_titleController.text.trim()} at $taskDateTime');
    print('Has reminder: $_hasReminder');

    // Check if the task time is in the past for reminders
    if (taskDateTime.isBefore(DateTime.now()) && _hasReminder) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot set reminder for past time. Please select a future time.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Cancel existing notification if it exists
    if (widget.task.hasReminder && widget.task.notificationId != null) {
      final notificationService = NotificationService();
      await notificationService.cancelNotification(widget.task.notificationId!);
      print('Cancelled existing notification: ${widget.task.notificationId}');
    }

    // Update the task properties
    widget.task.title = _titleController.text.trim();
    widget.task.description = _descriptionController.text.trim();
    widget.task.dateTime = taskDateTime;
    widget.task.hasReminder = _hasReminder;
    
    // Clear notification ID if reminder is disabled
    if (!_hasReminder) {
      widget.task.notificationId = null;
    }
    
    // Save the task
    await widget.task.save();
    print('Task updated and saved: ${widget.task.title} at ${widget.task.dateTime}');

    // Schedule new notification if needed
    if (_hasReminder) {
      final notificationService = NotificationService();
      await notificationService.scheduleNotification(widget.task);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task updated with reminder set for ${_selectedTime.format(context)}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
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
              'Edit Task',
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
                Expanded(
                  child: Text(
                    'Set reminder with voice alert',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                if (_hasReminder) ...[
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      final notificationService = NotificationService();
                      await notificationService.testVoiceAlert();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Test 🔊',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
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
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

