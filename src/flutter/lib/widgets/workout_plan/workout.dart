import 'package:auksine_bycke/utils/exercise_data.dart';
import 'package:auksine_bycke/utils/workout_tag.dart';
import 'package:auksine_bycke/widgets/workout_plan/exercise.dart';
import 'package:flutter/material.dart';

class Workout extends StatefulWidget {
  final String name;
  final List<ExerciseData> exercises;
  final List<WorkoutTag> tags;

  Workout({
    super.key,
    required this.name,
    List<ExerciseData>? exercises,
    List<WorkoutTag>? tags,
  }) : exercises = exercises ?? [],
    tags = tags ?? [];

  @override
  State<StatefulWidget> createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> {
  late final String _name = widget.name;
  late final List<ExerciseData> _exercises = widget.exercises;
  late final List<WorkoutTag> _tags = widget.tags;

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

  void addTag(WorkoutTag tag) {
    setState(() {
      _tags.add(tag);
    });
  }

  void removeTag(WorkoutTag tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        if(_tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.start,
              children: _tags.map((tag) => Chip(
                label: Text(tag.name),
                labelStyle: const TextStyle(fontSize: 11),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ),
        Column(
          children: _exercises.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: entry.key < _exercises.length - 1 ? 10 : 0),
              child: Exercise(exerciseData: entry.value),
            );
          }).toList(),
        ),
      ],
    );
  }
}