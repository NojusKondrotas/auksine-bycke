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

  void _showCalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const OneRepMaxSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        children: [
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
            leading: const Icon(Icons.notification_add),
            title: const Text('Enable notifications'),
            enabled: _enabled,
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
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('1RM Calculator'),
            subtitle: const Text('Calculate your potential'),
            onTap: _showCalculator,
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Us'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            onTap: () {
              // login stuff
            },
          ),
        ],
      ),
    );
  }
}

class OneRepMaxSheet extends StatefulWidget {
  const OneRepMaxSheet({super.key});

  @override
  State<OneRepMaxSheet> createState() => _OneRepMaxSheetState();
}

class _OneRepMaxSheetState extends State<OneRepMaxSheet> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  String _result = "Enter details";

  void _calculate() {
    double weight = double.tryParse(_weightController.text) ?? 0;
    int reps = int.tryParse(_repsController.text) ?? 0;

    if (weight > 0 && reps > 0) {
      // Brzycki formula
      double max = weight * (36/(37-reps));
      setState(() {
        _result = "Estimated 1RM: ${max.toStringAsFixed(1)} kg";
      });
    } else {
      setState(() {
        _result = "Please enter valid numbers";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        left: 25,
        right: 25,
        top: 25,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _result,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Weight lifted per rep",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _repsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Total reps performed",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text("Calculate"),
            ),
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("About us"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Auksinė Byckė",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
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
              context,
            ),
            _buildPunctualPoint(
              Icons.storage,
              "Privacy and security",
              "All data is stored only on your device.",
              context,
            ),
            _buildPunctualPoint(
              Icons.trending_up,
              "Motivation",
              "Helps you stay motivated to reach your goals.",
              context,
            ),
            _buildPunctualPoint(
              Icons.attach_money,
              "Free",
              "Open sourced.",
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPunctualPoint(
    IconData icon,
    String title,
    String description,
    BuildContext context,
  ) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? Colors.blueAccent : Colors.black,
            size: 30,
          ),
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
