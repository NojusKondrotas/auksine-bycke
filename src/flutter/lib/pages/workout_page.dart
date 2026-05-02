import 'package:auksine_bycke/pages/exercises_browser_page.dart';
import 'package:auksine_bycke/utils/UnitSystem.dart';
import 'package:auksine_bycke/utils/exercise_info.dart';
import 'package:flutter/material.dart';
import 'package:auksine_bycke/database/database_helper.dart';
import 'package:auksine_bycke/workouts/workout_models.dart';
import 'package:auksine_bycke/utils/exercise_catalog.dart';
import 'package:auksine_bycke/pages/workout_summary_page.dart';
import 'package:flutter/services.dart';
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
  bool isRoutineMode = false;
  int restDuration = 90; // cia default value
  int currentRestSeconds = 0;
  Timer? restTimer;

  List<Exercise> exercises = [];

  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _workoutNameController =
  TextEditingController();

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

  // ================ REST TIMER ================

  void startRestTimer() {
    if (isRoutineMode) return;

    restTimer?.cancel();
    setState(() => currentRestSeconds = restDuration);

    restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (currentRestSeconds > 0) {
        setState(() => currentRestSeconds--);
      } else {
        t.cancel();
        _handleRestOver();
      }
    });
  }

  void _handleRestOver() {
    HapticFeedback.vibrate();
    debugPrint("brrrrr brrr brrrrrrrr");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Rest over, start your set."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showTimerConfig() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set Rest Duration"),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${restDuration} seconds",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: restDuration.toDouble(),
                    min: 30,
                    max: 300,
                    divisions: 9,
                    label: "${restDuration}s",
                    onChanged: (double value) {
                      setDialogState(() => restDuration = value.toInt());
                      setState(() => restDuration = value.toInt());
                    },
                  ),
                  const Text("Adjust rest time between sets (30s - 5m)"),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // ================= ROUTINES =================

  Future<List<WorkoutModel>> getRoutines() async {
    final all = await DatabaseHelper.instance.getAllWorkouts();
    return all.where((w) => w.name.startsWith('[ROUTINE]')).toList();
  }

  void startRoutine(WorkoutModel routine) async {
    workoutName = routine.name.replaceFirst('[ROUTINE] ', '');
    _workoutNameController.text = workoutName;

    List<Exercise> routineExercises = [];

    for (final exModel in routine.exercises) {
      final info = getExerciseById(exModel.exerciseRefId);
      routineExercises.add(
        Exercise(
          exercise: info,
          sets: exModel.sets
              .map((s) => WorkoutSet(reps: s.reps, weight: s.weight))
              .toList(),
        ),
      );
    }

    setState(() {
      exercises = routineExercises;
      workoutStarted = true;
      isRoutineMode = false;
      seconds = 0;
    });

    setState(() {
      exercises = routineExercises;
      workoutStarted = true;
      isRoutineMode = false;
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
                      final exerciseInfo = getExerciseById(e.exerciseRefId); // lookup from catalog
                      final exerciseName = exerciseInfo?.name ?? 'Unknown Exercise';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• $exerciseName'), // now show name instead of ID
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

  // ================= SAVE =================

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter workout name')),
      );
      return;
    }

    if (exercises.any((e) => e.exercise == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select all exercises')),
      );
      return;
    }

    // ===== SAVE ROUTINE =====
    if (isRoutineMode) {
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
          'exercise_ref_id': ex.exercise!.id,
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
        const SnackBar(content: Text('Routine saved!')),
      );

      setState(() {
        workoutStarted = false;
        exercises = [];
        workoutName = '';
        _workoutNameController.clear();
      });

      return;
    }

    // ===== NORMAL WORKOUT =====
    stopTimer();
    await _showRatingDialog();

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
     
    // PR tikrinimas
    final List<String> personalRecords = [];
    for (final exercise in exercises) {
      if (exercise.exercise == null) continue;
      final prevMax = await DatabaseHelper.instance.getMaxWeightForExercise(exercise.exercise!.id);
      final currentMax = exercise.sets.fold<double>(0, (max, s) => s.weight > max ? s.weight : max);
      if (currentMax > prevMax) {
        personalRecords.add('${exercise.exercise!.name}: ${currentMax.toStringAsFixed(1)} kg');
      }
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSummaryPage(
          workout: workout,
          personalRecords: personalRecords,
          onSave: () async {
            await DatabaseHelper.instance.saveWorkout(workout);
            setState(() {
              workoutStarted = false;
              exercises = [];
              seconds = 0;
              workoutName = '';
              _selectedRating = 0;
              _commentController.clear();
              _workoutNameController.clear();
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _commentController.dispose();
    _workoutNameController.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout"),
        actions: [
          if (workoutStarted && !isRoutineMode)
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: ActionChip(
                avatar: const Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: Colors.blue,
                ),
                label: Text("Rest: ${restDuration}s"),
                onPressed: _showTimerConfig,
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
      ),
      body: workoutStarted
          ? Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _workoutNameController,
                        decoration: const InputDecoration(labelText: "Workout Name"),
                        onChanged: (val) => workoutName = val,
                      ),
                      const SizedBox(height: 16),
                      if (!isRoutineMode)
                        Text(
                          formattedTime,
                          style: const TextStyle(
                              fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 8),
                      if (!isRoutineMode)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: startTimer, child: const Text("Start")),
                            const SizedBox(width: 16),
                            ElevatedButton(
                                onPressed: stopTimer, child: const Text("Stop")),
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
                              onSetCompleted: startRestTimer,
                            );
                          },
                        ),
                      ),
                      ElevatedButton(
                          onPressed: addExercise,
                          child: const Text("Add Exercise")),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: saveWorkout,
                        child: Text(isRoutineMode ? "Save Routine" : "Save Workout"),
                      ),
                      if (currentRestSeconds > 0) const SizedBox(height: 80),
                    ],
                  ),
                ),

                if (currentRestSeconds > 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      child: SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.timer, color: Colors.white),
                                const SizedBox(width: 10),
                                Text(
                                  "Resting: ${currentRestSeconds}s",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => setState(() => currentRestSeconds += 30),
                                  child: const Text("+30s", style: TextStyle(color: Colors.white)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_next, color: Colors.white),
                                  onPressed: () {
                                    restTimer?.cancel();
                                    setState(() => currentRestSeconds = 0);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        workoutStarted = true;
                        isRoutineMode = false;
                      });
                      startTimer();
                    },
                    child: const Text("New Workout"),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        workoutStarted = true;
                        isRoutineMode = true;
                      });
                    },
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
  ExerciseInfo? exercise;
  List<WorkoutSet> sets;
  Exercise({required this.exercise, required this.sets});
}

class WorkoutSet {
  int reps;
  double weight;
  bool isCompleted = false;

  late TextEditingController repsController;
  late TextEditingController weightController;

  WorkoutSet({
    required this.reps,
    required this.weight,
  }) {
    repsController = TextEditingController(text: reps.toString());
    weightController = TextEditingController(text: weight.toString());
  }

  void dispose() {
    repsController.dispose();
    weightController.dispose();
  }
}

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final ValueChanged<Exercise> onChanged;
  final VoidCallback onSetCompleted;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onChanged,
    required this.onSetCompleted,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {

  @override
  void dispose() {
    // išvalom controllerius kai widget sunaikinamas
    for (var s in widget.exercise.sets) {
      s.dispose();
    }
    super.dispose();
  }

  void addSet() {
    setState(() {
      widget.exercise.sets.add(
        WorkoutSet(reps: 0, weight: 0),
      );
      widget.onChanged(widget.exercise);
      widget.onSetCompleted();
    });
  }

  void removeSet(int index) {
    setState(() {
      widget.exercise.sets[index].dispose();
      widget.exercise.sets.removeAt(index);
      widget.onChanged(widget.exercise);
    });
  }

  @override
  Widget build(BuildContext context) {
    final units = UnitSystemScope.of(context);
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

            // SETAI
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
                        controller: s.repsController,
                        decoration: const InputDecoration(labelText: "Reps"),
                        onChanged: (val) => s.reps = int.tryParse(val) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: s.weightController,
                        decoration: InputDecoration(labelText: "Weight ${units.weightLabel()}"),
                        onChanged: (val) =>
                            s.weight = double.tryParse(val) ?? 0,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => removeSet(index),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: addSet,
              child: const Text("Add Set"),
            ),
          ],
        ),
      ),
    );
  }
}