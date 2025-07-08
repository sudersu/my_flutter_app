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

    final DateTime now = DateTime.now();
    final bool isToday = _selectedDate.year == now.year && 
                        _selectedDate.month == now.month && 
                        _selectedDate.day == now.day;

    print('Editing task - Original: ${widget.task.title} at ${widget.task.dateTime}');
    print('Editing task - New: ${_titleController.text.trim()} at $taskDateTime');
    print('Has reminder: $_hasReminder');
    print('Is today: $isToday');

    // Smart time validation for edit: Only check if it's today AND reminder is enabled
    if (_hasReminder && isToday && taskDateTime.isBefore(now)) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Past Time Selected', style: TextStyle(color: Colors.white)),
          content: Text(
            'The selected time (${_selectedTime.format(context)}) is in the past for today.\n\nWhat would you like to do?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'no_reminder'),
              child: Text('Update without reminder', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'tomorrow'),
              child: Text('Schedule for tomorrow', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );

      if (result == 'cancel' || result == null) {
        return;
      } else if (result == 'no_reminder') {
        _hasReminder = false;
      } else if (result == 'tomorrow') {
        _selectedDate = _selectedDate.add(Duration(days: 1));
      }
    }

    // Recalculate taskDateTime if date was changed
    final DateTime finalTaskDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
      0,
      0,
    );

    try {
      // Cancel existing notification if it exists
      if (widget.task.hasReminder && widget.task.notificationId != null) {
        final notificationService = NotificationService();
        await notificationService.cancelNotification(widget.task.notificationId!);
        print('Cancelled existing notification: ${widget.task.notificationId}');
      }

      // Update the task properties
      widget.task.title = _titleController.text.trim();
      widget.task.description = _descriptionController.text.trim();
      widget.task.dateTime = finalTaskDateTime;
      widget.task.hasReminder = _hasReminder;
      
      // Clear notification ID if reminder is disabled
      if (!_hasReminder) {
        widget.task.notificationId = null;
      }
      
      // Save the task to Hive
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
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      print('Error updating task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                  SizedBox(width: 4),
                  InkWell(
                    onTap: () async {
                      final notificationService = NotificationService();
                      await notificationService.testVoiceAlert();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Voice 🔊',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  InkWell(
                    onTap: () async {
                      final notificationService = NotificationService();
                      await notificationService.testImmediateNotification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Test notification will appear in 3 seconds. Tap it to test voice.'),
                          backgroundColor: Colors.blue,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Notify �',
                        style: TextStyle(color: Colors.white, fontSize: 10),
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

