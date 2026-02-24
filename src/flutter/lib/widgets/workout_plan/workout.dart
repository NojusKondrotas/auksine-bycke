import 'dart:collection';

import 'package:auksine_bycke/utils/exercise_data.dart';
import 'package:auksine_bycke/utils/workout_tags/workout_tag.dart';
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
  late final String _name;
  late final List<ExerciseData> _exercises;
  late final LinkedHashSet<WorkoutTag> _tags;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _exercises = List.of(widget.exercises);
    _tags = LinkedHashSet.of(widget.tags);
  }

  void addExercise(String name, int sets, int reps) {
    setState(() {
      _exercises.add(ExerciseData(name: name, sets: sets, reps: reps));
    });
  }

  void removeExercise(ExerciseData exercise) {
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
                label: Text(tag.getTag()),
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