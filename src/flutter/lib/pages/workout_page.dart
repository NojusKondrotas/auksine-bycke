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
  late TextEditingController workoutNameController;
  String workoutName = '';
  int seconds = 0;
  Timer? timer;
  bool workoutStarted = false;
  bool isRoutineMode = false;
  List<Exercise> exercises = [];

  @override
  void initState() {
    super.initState();
    workoutNameController = TextEditingController();
  }

  Future<List<WorkoutModel>> getRoutines() async {
    final all = await DatabaseHelper.instance.getAllWorkouts();
    return all.where((w) => w.name.startsWith('[ROUTINE]')).toList();
  }

  void startRoutine(WorkoutModel routine) {
    final cleanName = routine.name.replaceFirst('[ROUTINE] ', '');

    setState(() {
      workoutStarted = true;
      isRoutineMode = false;

      workoutName = cleanName;
      workoutNameController.text = cleanName; // ✅ key line

      exercises = routine.exercises
          .map((e) => Exercise(
        name: e.name,
        sets: e.sets
            .map((s) => WorkoutSet(
          reps: s.reps,
          weight: s.weight,
        ))
            .toList(),
      ))
          .toList();

      seconds = 0;
    });
  }

  void showRoutinePicker() async {
    final routines = await getRoutines();

    if (routines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No routines found')),
      );
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Routine'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final r = routines[index];

                return ListTile(
                  title: Text(r.name.replaceFirst('[ROUTINE] ', '')),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: r.exercises.map((e) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ${e.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ...e.sets.asMap().entries.map((entry) {
                            final i = entry.key + 1;
                            final s = entry.value;
                            return Text('   Set $i: ${s.reps} reps × ${s.weight} kg');
                          }),
                        ],
                      );
                    }).toList(),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    startRoutine(r);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

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

  if (isRoutineMode) {
    try {
      stopTimer();

      final db = await DatabaseHelper.instance.database;

      final routineId = await db.insert('workouts', {
        'name': '[ROUTINE] $workoutName',
        'duration': 0,
        'date': DateTime.now().toIso8601String(),
        'rating': 0,
        'comment': '',
      });

      for (final ex in exercises) {
        final exerciseId = await db.insert('exercises', {
          'workout_id': routineId,
          'name': ex.name,
        });

        for (final set in ex.sets) {
          await db.insert('sets', {
            'exercise_id': exerciseId,
            'reps': set.reps,
            'weight': set.weight,
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine išsaugota!')),
      );

      setState(() {
        workoutStarted = false;
        exercises = [];
        workoutName = '';
        seconds = 0;
      });

      return;
    } catch (e) {
      print('Routine save error: $e');
      return;
    }
  }

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
      rating: 0,
      comment: '',
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
                    controller: workoutNameController,
                    decoration: const InputDecoration(labelText: "Workout Name"),
                    onChanged: (val) => workoutName = val,
                  ),
                  const SizedBox(height: 16),
                  if (!isRoutineMode) ( Text(
                    formattedTime,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  )),
                  const SizedBox(height: 8),
                  if (!isRoutineMode)
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
                  ElevatedButton(
                  onPressed: saveWorkout,
                  child: Text(isRoutineMode ? "Save Routine" : "Save Workout"),
                  ),
                ],
              ),
            )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => setState(() {
                workoutStarted = true;
                isRoutineMode = false;
              }),
              child: const Text("New Workout"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {
                workoutStarted = true;
                isRoutineMode = true;
              }),
              child: const Text("Create Routine"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: showRoutinePicker,
              child: const Text("Start Routine"),
            ),
          ],
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
  late TextEditingController nameController;
  final List<TextEditingController> repsControllers = [];
  final List<TextEditingController> weightControllers = [];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.exercise.name);

    for (final s in widget.exercise.sets) {
      repsControllers.add(TextEditingController(text: s.reps.toString()));
      weightControllers.add(TextEditingController(text: s.weight.toString()));
    }
  }

  void addSet() {
    setState(() {
      widget.exercise.sets.add(WorkoutSet(reps: 0, weight: 0));
      repsControllers.add(TextEditingController(text: '0'));
      weightControllers.add(TextEditingController(text: '0'));
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
              controller: nameController,
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
                        controller: repsControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Reps"),
                        onChanged: (val) =>
                        s.reps = int.tryParse(val) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: weightControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Weight"),
                        onChanged: (val) =>
                        s.weight = double.tryParse(val) ?? 0,
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