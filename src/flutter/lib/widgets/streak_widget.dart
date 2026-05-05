import 'package:flutter/material.dart';
import 'package:auksine_bycke/database/database_helper.dart';

class StreakWidget extends StatefulWidget {
  const StreakWidget({super.key});

  @override
  State<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget> {
  int streak = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadStreak();
  }

  Future<void> loadStreak() async {
    final value = await DatabaseHelper.instance.getWorkoutStreak();
    if (mounted) {
      setState(() => streak = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🔥", style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Text(
              "$streak day streak",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}