import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../widgets/edit_task_dialog.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditTaskDialog(task: task),
    );
  }

  void _deleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Delete Task', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this task?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              task.delete();
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleComplete() {
    task.isCompleted = !task.isCompleted;
    task.save();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showEditDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleComplete,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isCompleted ? Colors.green : Colors.white54,
                          width: 2,
                        ),
                        color: task.isCompleted ? Colors.green : Colors.transparent,
                      ),
                      child: task.isCompleted
                          ? Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: task.isCompleted ? Colors.white54 : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.white54),
                    color: Theme.of(context).cardColor,
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(context);
                      } else if (value == 'delete') {
                        _deleteTask(context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Edit', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: task.isCompleted ? Colors.white38 : Colors.white70,
                  ),
                ),
              ],
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.white54, size: 16),
                  SizedBox(width: 4),
                  Text(
                    dateFormat.format(task.dateTime),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.access_time, color: Colors.white54, size: 16),
                  SizedBox(width: 4),
                  Text(
                    timeFormat.format(task.dateTime),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  if (task.hasReminder) ...[
                    SizedBox(width: 16),
                    Icon(Icons.notifications_active, color: Colors.orange, size: 16),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

