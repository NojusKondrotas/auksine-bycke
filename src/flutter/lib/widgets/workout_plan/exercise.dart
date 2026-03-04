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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.exerciseData.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const dotSize = 3.0;
                const dotSpacing = 6.0;
                final count = (constraints.maxWidth / (dotSize + dotSpacing)).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(count, (_) => Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
                      shape: BoxShape.circle,
                    ),
                  )),
                );
              },
            ),
          ),
        ),
        Text(
          "${widget.exerciseData.sets} x ${widget.exerciseData.reps}",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}