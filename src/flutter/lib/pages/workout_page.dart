import 'package:flutter/material.dart';
import 'package:auksine_bycke/database/database_helper.dart';
import 'package:auksine_bycke/workouts/workout_models.dart';
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
  List<Exercise> exercises = [];

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => seconds++);
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void addExercise() {
    setState(() {
      exercises.add(Exercise(name: '', sets: [WorkoutSet(reps: 0, weight: 0)]));
    });
  }

   void saveWorkout() async {
  print('1. Save paspaustas');
  print('workoutName: $workoutName');

  if (workoutName.isEmpty) {
    print('2. Vardas tuscias - rodomas snackbar');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Įvesk workout pavadinimą!')),
    );
    return;
  }

  print('3. Bandoma issaugoti i DB');

  try {
    stopTimer();
    final workout = WorkoutModel(
      name: workoutName,
      duration: seconds,
      date: DateTime.now(),
      exercises: exercises
          .map((e) => ExerciseModel(
                name: e.name,
                sets: e.sets
                    .map((s) => SetModel(reps: s.reps, weight: s.weight))
                    .toList(),
              ))
          .toList(),
    );

    await DatabaseHelper.instance.saveWorkout(workout);
    print('4. Issaugota sekmingai');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout išsaugotas!')),
      );
      setState(() {
        workoutStarted = false;
        exercises = [];
        seconds = 0;
        workoutName = '';
      });
    }
  } catch (e) {
    print('KLAIDA: $e');
  }
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
      body: workoutStarted
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: "Workout Name"),
                    onChanged: (val) => workoutName = val,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    formattedTime,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(onPressed: startTimer, child: const Text("Start")),
                      const SizedBox(width: 16),
                      ElevatedButton(onPressed: stopTimer, child: const Text("Stop")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        return ExerciseCard(
                          exercise: exercises[index],
                          onChanged: (ex) => setState(() => exercises[index] = ex),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(onPressed: addExercise, child: const Text("Add Exercise")),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: saveWorkout, child: const Text("Save Workout")),
                ],
              ),
            )
          : Center(
              child: ElevatedButton(
                onPressed: () => setState(() => workoutStarted = true),
                child: const Text("New Workout"),
              ),
            ),
    );
  }
}

class Exercise {
  String name;
  List<WorkoutSet> sets;
  Exercise({required this.name, required this.sets});
}

class WorkoutSet {
  int reps;
  double weight;
  WorkoutSet({required this.reps, required this.weight});
}

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final ValueChanged<Exercise> onChanged;
  const ExerciseCard({super.key, required this.exercise, required this.onChanged});

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  void addSet() {
    setState(() {
      widget.exercise.sets.add(WorkoutSet(reps: 0, weight: 0));
      widget.onChanged(widget.exercise);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Exercise Name"),
              onChanged: (val) {
                widget.exercise.name = val;
                widget.onChanged(widget.exercise);
              },
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.exercise.sets.length,
              itemBuilder: (context, index) {
                final s = widget.exercise.sets[index];
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Reps"),
                        onChanged: (val) => s.reps = int.tryParse(val) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Weight"),
                        onChanged: (val) => s.weight = double.tryParse(val) ?? 0,
                      ),
                    ),
                  ],
                );
              },
            ),
            TextButton(onPressed: addSet, child: const Text("Add Set")),
          ],
        ),
      ),
    );
  }
}