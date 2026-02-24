import 'package:flutter/material.dart';
import 'dart:async';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  String workoutName = '';
  int seconds = 0;
  Timer? timer;
  bool workoutStarted = false;

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => seconds++);
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  String get formattedTime {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Workout")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: workoutStarted
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: "Workout Name"),
                    onChanged: (val) => workoutName = val,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      formattedTime,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(onPressed: startTimer, child: const Text("Start")),
                      const SizedBox(width: 16),
                      ElevatedButton(onPressed: stopTimer, child: const Text("Stop")),
                    ],
                  ),
                ],
              )
            : Center(
                child: ElevatedButton(
                  onPressed: () => setState(() => workoutStarted = true),
                  child: const Text("New Workout"),
                ),
              ),
      ),
    );
  }
}