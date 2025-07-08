import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'screens/home_screen.dart';
import 'models/task.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');
  
  // Initialize Mobile Ads
  MobileAds.instance.initialize();
  
  // Initialize Notification Service
  await NotificationService().initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyList Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF1E3A8A), // Deep blue
        scaffoldBackgroundColor: Color(0xFF0F172A), // Dark navy
        cardColor: Color(0xFF1E293B), // Slate gray
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF3B82F6), // Bright blue
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF334155),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.white54),
          labelStyle: TextStyle(color: Colors.white70),
        ),
        cardTheme: CardThemeData(
          color: Color(0xFF1E293B),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

