import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Initialize TTS
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) async {
    // Handle notification tap
    final payload = response.payload;
    if (payload != null) {
      print('Notification tapped with payload: $payload');
      // Parse the task title from payload and speak it
      await _speakTaskReminder(payload);
    }
  }

  Future<void> _speakTaskReminder(String taskTitle) async {
    try {
      // Check if voice reminders are enabled
      final settingsBox = await Hive.openBox('settings');
      final voiceEnabled = settingsBox.get('voiceRemindersEnabled', defaultValue: true);
      
      if (voiceEnabled) {
        await _flutterTts.speak("Reminder: $taskTitle");
      }
    } catch (e) {
      // If settings box fails, just speak the reminder
      await _flutterTts.speak("Reminder: $taskTitle");
    }
  }

  Future<void> scheduleNotification(Task task) async {
    await initialize();

    // Cancel existing notification if it exists
    if (task.notificationId != null) {
      await cancelNotification(task.notificationId!);
    }

    final notificationId = Random().nextInt(100000);
    task.notificationId = notificationId;
    await task.save();

    // Check if the scheduled time is in the future
    if (task.dateTime.isBefore(DateTime.now())) {
      print('Scheduled time is in the past: ${task.dateTime}');
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    final scheduledDate = tz.TZDateTime.from(task.dateTime, tz.local);
    
    print('Scheduling notification for: ${scheduledDate}');
    print('Current time: ${tz.TZDateTime.now(tz.local)}');

    try {
      await _notifications.zonedSchedule(
        notificationId,
        'Task Reminder 📝',
        '${task.title}\n${task.description.isNotEmpty ? task.description : "Time to complete your task!"}',
        scheduledDate,
        platformChannelSpecifics,
        payload: task.title,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      print('Notification scheduled successfully with ID: $notificationId');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Test notification to check if voice alerts work
  Future<void> showTestNotification() async {
    await initialize();
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_notification',
      'Test Notifications',
      channelDescription: 'Test notifications for debugging',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notifications.show(
      99999,
      'Voice Alert Test 🔊',
      'Tap this notification to test voice alert',
      platformChannelSpecifics,
      payload: 'Test Voice Alert',
    );
  }

  // Direct voice test
  Future<void> testVoiceAlert() async {
    await _flutterTts.speak("Voice alert test successful! Your reminders will work like this.");
  }
}

