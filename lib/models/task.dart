import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime dateTime;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  bool hasReminder;

  @HiveField(5)
  int? notificationId;

  Task({
    required this.title,
    this.description = '',
    required this.dateTime,
    this.isCompleted = false,
    this.hasReminder = false,
    this.notificationId,
  });

  @override
  String toString() {
    return 'Task{title: $title, description: $description, dateTime: $dateTime, isCompleted: $isCompleted, hasReminder: $hasReminder}';
  }
}

