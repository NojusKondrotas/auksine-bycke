import 'package:flutter/material.dart';

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

          // 🌙 Dark Mode Toggle (NEW)
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

          // 🔔 Notifications (UNCHANGED)
          ListTile(
            leading: const Icon(Icons.notification_add),
            title: const Text('Enable notifications'),
            splashColor: Colors.grey,
            enabled: _enabled,
            onTap: () {
              setState(() {
                _enabled = !_enabled;
              });
            },
            trailing: Switch(
              onChanged: (bool value) {
                setState(() {
                  _enabled = value;
                });
              },
              value: _enabled,
            ),
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
            title: const Text('Log out',
                style: TextStyle(color: Colors.red)),
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
      appBar: AppBar(title: const Text("About us"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Auksinė Byckė",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Created by students, seeking an easy and free way to track your fitness journey.",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 30),

            _buildPunctualPoint(
              Icons.flash_on,
              "Effectiveness",
              "Fast way to track your progress.",
            ),
            _buildPunctualPoint(
              Icons.storage,
              "Privacy and security",
              "All data is stored only on your device.",
            ),
            _buildPunctualPoint(
              Icons.trending_up,
              "Motivation",
              "Helps you stay motivated to reach your goals.",
            ),
            _buildPunctualPoint(
              Icons.attach_money,
              "Free",
              "Open sourced.",
            )
          ],
        ),
      ),
    );
  }
  Widget _buildPunctualPoint(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(description, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}