import 'package:flutter/material.dart';

class Exercise extends StatefulWidget {
  final String name;
  final int sets;
  final int reps;

  const Exercise({
    super.key,
    required this.name,
    required this.sets,
    required this.reps,
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
          widget.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
        ),
        Row(
          spacing: 10,
          children: [
            Container(
              width: 1,
              height: 20,
              color: Color.fromARGB(255, 31, 31, 31),
            ),
            Text(
              "${widget.sets} x ${widget.reps}",
              style: TextStyle(fontSize: 16),
            ),
          ],
        )
      ],
    );
  }
}