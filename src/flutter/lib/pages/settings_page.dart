// visa sita gal reiks imest i profile page kai registerint normaliai iseis
// dar daug random settings reiktu pridet

import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

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
          ListTile(
            leading: const Icon(Icons.notification_add),
            title: const Text('Enable notifications'),
            splashColor: Colors.grey,
            iconColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
              return Colors.black;
            }),
            textColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
              return Colors.black;
            }),
            enabled: _enabled,
            onTap: () {
              setState(() {
                _enabled = !_enabled;
              });
              //notification on/off logic
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
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Us'),
            splashColor: Colors.grey,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AboutScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
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
      body: Text(""), //missing text
    );
  }
}
