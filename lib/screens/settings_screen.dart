import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box settingsBox;
  bool _voiceRemindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  void _initSettings() async {
    settingsBox = await Hive.openBox('settings');
    setState(() {
      _voiceRemindersEnabled = settingsBox.get('voiceRemindersEnabled', defaultValue: true);
    });
  }

  void _toggleVoiceReminders(bool value) {
    setState(() {
      _voiceRemindersEnabled = value;
    });
    settingsBox.put('voiceRemindersEnabled', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.volume_up, color: Colors.white70),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Voice Reminders',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Enable voice alerts for task reminders',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _voiceRemindersEnabled,
                          onChanged: _toggleVoiceReminders,
                          activeColor: Color(0xFF3B82F6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'About',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white70),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'App Version',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                '1.0.0',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

