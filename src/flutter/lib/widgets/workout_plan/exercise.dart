import 'package:auksine_bycke/utils/exercise_data.dart';
import 'package:flutter/material.dart';

class Exercise extends StatefulWidget {
  final ExerciseData exerciseData;

  const Exercise({
    super.key,
    required this.exerciseData,
  });

  @override
  State<StatefulWidget> createState() => _ExerciseState();
}

class _ExerciseState extends State<Exercise> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.exerciseData.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${widget.exerciseData.sets} x ${widget.exerciseData.reps}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 1,
          width: double.infinity,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
        ),
      ],
    );
  }
}