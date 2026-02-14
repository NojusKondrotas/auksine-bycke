import 'package:auksine_bycke/utils/exercise_data.dart';
import 'package:auksine_bycke/widgets/workout_plan/exercise.dart';
import 'package:flutter/material.dart';

class Workout extends StatefulWidget {
  final String name;
  final List<ExerciseData>? exercises;

  const Workout({
    super.key,
    required this.name,
    this.exercises
  });

  @override
  State<StatefulWidget> createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> {
  late String _name;
  late List<ExerciseData> _exercises;

  @override
  void initState() {
    super.initState();

    _name = widget.name;
    _exercises = widget.exercises?.toList() ?? [];
  }

  void addExercise(String name, int sets, int reps) {
    setState(() {
      _exercises.add(ExerciseData(name: name, sets: sets, reps: reps));
    });
  }

  void popExercise(ExerciseData exercise) {
    setState(() {
      _exercises.remove(exercise);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: _exercises.isEmpty
            ? const Center(
              child: Text('No exercises yet. Add some!'),
            )
            : ListView.separated(
              itemCount: _exercises.length,
              separatorBuilder: (context, index) => SizedBox(height: 10),
              itemBuilder: (context, index) {
                return Exercise(exerciseData: _exercises[index]);
              }
            ),
        ),
      ],
    );
  }
}