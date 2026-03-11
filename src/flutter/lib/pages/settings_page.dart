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

    // 🔔 Notifications toggle
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

    // 🧪 Test notification button
    ListTile(
      leading: const Icon(Icons.bug_report),
      title: const Text("Test Notification"),
      splashColor: Colors.grey,
      onTap: () async {
        if (!_enabled) {
          print("Notifications are disabled");
          return;
        }

        print("Test notification button pressed");
        await NotificationService.showInstantTestNotification();
      },
    ),

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

    // 🚪 Logout
    ListTile(
    leading: const Icon(Icons.logout, color: Colors.red),
    title: const Text(
    'Log out',
    style: TextStyle(color: Colors.red),
    ),
    splashColor: Colors.grey,
    onTap: () {
    // login stuff
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
      body: const Center(
        child: Text("Auksinė byckė fitness app."),
      ),
    );
  }
}
