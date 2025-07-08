import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  void _shareApp(BuildContext context) {
    // In a real app, you would use share_plus package
    // For now, we'll just copy to clipboard
    Clipboard.setData(ClipboardData(text: 'Check out DailyList Pro - A simple and easy-to-use to-do list app with reminders!'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('App info copied to clipboard!'),
        backgroundColor: Color(0xFF3B82F6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.task_alt,
                size: 60,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'DailyList Pro',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
              ),
            ),
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'A simple and easy-to-use to-do list app with reminders.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Features:',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Add and manage tasks with dates and times\n'
                      '• Set voice reminders for important tasks\n'
                      '• Modern and attractive user interface\n'
                      '• Offline storage - no internet required\n'
                      '• Lightweight and fast performance',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _shareApp(context),
              icon: Icon(Icons.share),
              label: Text('Share App'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            Spacer(),
            Text(
              'Made with ❤️ using Flutter',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

