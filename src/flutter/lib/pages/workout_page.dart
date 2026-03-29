import 'package:auksine_bycke/pages/exercises_browser_page.dart';
import 'package:auksine_bycke/utils/exercise_info.dart';
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

  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

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
      exercises.add(
        Exercise(exercise: null, sets: [WorkoutSet(reps: 0, weight: 0)]),
      );
    });
  }

  String get formattedTime {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _showRatingDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Rate your workout"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("How did it go?"),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() => _selectedRating = index + 1);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Comments (optional)...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _selectedRating = 0;
                    Navigator.pop(context);
                  },
                  child: const Text("Skip"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void saveWorkout() async {
    if (workoutName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter workout name:')));
      return;
    }

    if (exercises.any((e) => e.exercise == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a predefined exercise for each card.'),
        ),
      );
      return;
    }

    stopTimer();
    await _showRatingDialog();

    try {
      final workout = WorkoutModel(
        name: workoutName,
        duration: seconds,
        date: DateTime.now(),
        rating: _selectedRating,
        comment: _commentController.text,
        exercises: exercises
            .map(
              (e) => ExerciseModel(
                exerciseRefId: e.exercise!.id,
                sets: e.sets
                    .map((s) => SetModel(reps: s.reps, weight: s.weight))
                    .toList(),
              ),
            )
            .toList(),
      );

      await DatabaseHelper.instance.saveWorkout(workout);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Workout saved!')));
        setState(() {
          workoutStarted = false;
          exercises = [];
          seconds = 0;
          workoutName = '';
          _selectedRating = 0;
          _commentController.clear();
        });
      }
    } catch (e) {
      debugPrint('KLAIDA: $e');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _commentController.dispose();
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
                    decoration: const InputDecoration(
                      labelText: "Workout Name",
                    ),
                    onChanged: (val) => workoutName = val,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: startTimer,
                        child: const Text("Start"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: stopTimer,
                        child: const Text("Stop"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        return ExerciseCard(
                          exercise: exercises[index],
                          onChanged: (ex) =>
                              setState(() => exercises[index] = ex),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: addExercise,
                    child: const Text("Add Exercise"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: saveWorkout,
                    child: const Text("Save Workout"),
                  ),
                ],
              ),
            )
          : Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() => workoutStarted = true);
                  startTimer();
                },
                child: const Text("New Workout"),
              ),
            ),
    );
  }
}

class Exercise {
  ExerciseInfo? exercise;
  List<WorkoutSet> sets;
  Exercise({required this.exercise, required this.sets});
}

class WorkoutSet {
  int reps;
  double weight;
  WorkoutSet({required this.reps, required this.weight});
}

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final ValueChanged<Exercise> onChanged;
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onChanged,
  });

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.exercise.exercise?.name ?? 'No exercise selected',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push<ExerciseInfo>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExerciseBrowserPage(),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        widget.exercise.exercise = result;
                        widget.onChanged(widget.exercise);
                      });
                    }
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Select Exercise'),
                ),
              ],
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
