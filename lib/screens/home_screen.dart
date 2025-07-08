import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_dialog.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Task> taskBox;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box<Task>('tasks');
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-7863737202117990/3391779583',
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text('About', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DailyList Pro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: _showMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: taskBox.listenable(),
              builder: (context, Box<Task> box, _) {
                if (box.values.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 80,
                          color: Colors.white24,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No tasks yet',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first task',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                final tasks = box.values.toList();
                tasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(task: tasks[index]);
                  },
                );
              },
            ),
          ),
          if (_isBannerAdReady && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add, size: 28),
        elevation: 8,
      ),
    );
  }
}

