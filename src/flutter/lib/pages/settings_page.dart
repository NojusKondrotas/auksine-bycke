import 'package:auksine_bycke/utils/UnitSystem.dart';
import 'package:flutter/material.dart';
import 'package:auksine_bycke/services/notification_service.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _enabled = true;
  String _permissionStatus = 'Checking...';
  String _lastTestResult = '';

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    final hasPermission = await NotificationService.checkPermissions();
    setState(() {
      _permissionStatus = hasPermission ? '✅ Granted' : '❌ Denied';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        children: [
          // 🌙 Dark Mode Toggle
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: widget.isDarkMode,
              onChanged: (bool value) {
                widget.onThemeChanged(value);
              },
            ),
          ),

          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Unit System'),
            subtitle: Text(
              UnitSystemScope.of(context).isMetric ? 'Metric' : 'Imperial',
            ),
            trailing: Switch(
              value: UnitSystemScope.of(context).isMetric,
              onChanged: (_) => UnitSystemScope.of(context).toggle(),
            ),
          ),

          // Notifications toggle
          ListTile(
            leading: const Icon(Icons.notification_add),
            title: const Text('Enable notifications'),
            splashColor: Colors.grey,
            trailing: Switch(
              value: _enabled,
              onChanged: (bool value) async {
                print("Notification switch pressed");

                setState(() {
                  _enabled = value;
                });

                if (value) {
                  print("Scheduling daily workout notification");

                  await NotificationService.scheduleDailyWorkout(
                    "Bench Press, Shoulder Press, Triceps",
                  );
                } else {
                  print("Cancelling workout notification");

                  await NotificationService.cancelDailyWorkout();
                }
              },
            ),
          ),

          //  Notification Testing Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notification Testing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Permission Status
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Permission Status'),
            subtitle: Text(_permissionStatus),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _checkPermissionStatus,
            ),
          ),

          // Test Result Display
          if (_lastTestResult.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _lastTestResult,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),

          // Test 1: Foreground Notification
          ListTile(
            leading: const Icon(Icons.phone_android, color: Colors.green),
            title: const Text('Test 1: Foreground Delivery'),
            subtitle: const Text('Tests notification while app is active'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              if (!_enabled) {
                setState(() {
                  _lastTestResult = '❌ Enable notifications first';
                });
                return;
              }

              setState(() {
                _lastTestResult = '📤 Sending foreground notification...';
              });

              await NotificationService.testForegroundNotification();

              setState(() {
                _lastTestResult =
                    '✅ Foreground notification sent!\nYou should see it appear now.';
              });
            },
          ),

          // Test 2: Background/Terminated Notification
          ListTile(
            leading: const Icon(Icons.schedule, color: Colors.orange),
            title: const Text('Test 2: Background/Terminated'),
            subtitle: const Text('Scheduled in 5s - minimize app to test'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              if (!_enabled) {
                setState(() {
                  _lastTestResult = '❌ Enable notifications first';
                });
                return;
              }

              setState(() {
                _lastTestResult =
                    '⏰ Notification scheduled for 5 seconds.\n\nMinimize or close the app now to test background/terminated delivery.';
              });

              await NotificationService.testBackgroundNotification();
            },
          ),

          // Test 3: Navigation Test
          ListTile(
            leading: const Icon(Icons.navigation, color: Colors.blue),
            title: const Text('Test 3: Navigation'),
            subtitle: const Text('Tap notification to navigate to Workouts'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              if (!_enabled) {
                setState(() {
                  _lastTestResult = '❌ Enable notifications first';
                });
                return;
              }

              setState(() {
                _lastTestResult =
                    '🎯 Navigation test notification sent!\n\nTap the notification to navigate to Workouts page.';
              });

              await NotificationService.testNavigationNotification();
            },
          ),

          // Run All Tests
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                if (!_enabled) {
                  setState(() {
                    _lastTestResult = '❌ Enable notifications first';
                  });
                  return;
                }

                setState(() {
                  _lastTestResult =
                      '🧪 Running all tests...\n\n1. Foreground test sent\n2. Background test scheduled (5s)\n3. Navigation test sent\n\nCheck your notifications!';
                });

                await NotificationService.testForegroundNotification();
                await Future.delayed(const Duration(milliseconds: 500));
                await NotificationService.testBackgroundNotification();
                await Future.delayed(const Duration(milliseconds: 500));
                await NotificationService.testNavigationNotification();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run All Tests'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),

          const Divider(),

          // ℹ About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Us'),
            splashColor: Colors.grey,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Us"), centerTitle: true),
      body: const Center(child: Text("Auksinė byckė fitness app.")),
    );
  }
}
