import 'package:auksine_bycke/utils/exercise_catalog.dart';
import 'package:flutter/material.dart';

class ExerciseBrowserPage extends StatelessWidget {
  const ExerciseBrowserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: predefinedExercises.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final exercise = predefinedExercises[index];
          return Card(
            child: ListTile(
              title: Text(exercise.name),
              subtitle: Text(exercise.shortDescription),
              trailing: const Icon(Icons.keyboard_arrow_down),
              onTap: () => Navigator.pop(context, exercise),
            ),
          );
        },
      ),
    );
  }
}
