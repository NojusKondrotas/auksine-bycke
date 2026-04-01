import 'package:auksine_bycke/utils/exercise_catalog.dart';
import 'package:flutter/material.dart';

class ExerciseBrowserPage extends StatefulWidget {
  const ExerciseBrowserPage({super.key});

  @override
  State<ExerciseBrowserPage> createState() => _ExerciseBrowserPageState();
}

class _ExerciseBrowserPageState extends State<ExerciseBrowserPage> {
  int? _expandedIndex;

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
          final isExpanded = _expandedIndex == index;

          return Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(exercise.name),
                  subtitle: Text(exercise.shortDescription),
                  trailing: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onTap: () => setState(
                        () => _expandedIndex = isExpanded ? null : index,
                  ),
                ),
                if (isExpanded) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise.fullDescription),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: () =>
                                Navigator.pop(context, exercise),
                            child: const Text('Select'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
