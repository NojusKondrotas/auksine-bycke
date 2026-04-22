import 'package:auksine_bycke/utils/exercise_catalog.dart';
import 'package:flutter/material.dart';

class ExerciseBrowserPage extends StatefulWidget {
  const ExerciseBrowserPage({super.key, this.selectable = true});

  final bool selectable;

  @override
  State<ExerciseBrowserPage> createState() => _ExerciseBrowserPageState();
}

class _ExerciseBrowserPageState extends State<ExerciseBrowserPage> {
  int? _expandedIndex;
  final List<GlobalKey> _keys = List.generate(
    predefinedExercises.length,
        (_) => GlobalKey(),
  );

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
            key: _keys[index],
            child: Column(
              children: [
                ListTile(
                  title: Text(exercise.name),
                  subtitle: Text('Muscles: ${exercise.bodyParts.join(', ')}\nBody parts: ${exercise.muscles.join(', ')}',),
                  trailing: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onTap: () {
                    setState(() => _expandedIndex = isExpanded ? null : index);
                    if (!isExpanded) {
                      Future.delayed(const Duration(milliseconds: 200), () {
                        Scrollable.ensureVisible(
                          _keys[index].currentContext!,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
                        );
                      });
                    }
                  },
                ),
                ClipRect(
                  child: AnimatedAlign(
                    alignment: Alignment.topCenter,
                    heightFactor: isExpanded ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: exercise.instructions.asMap().entries.map((entry) {
                                  final stepNumber = entry.key + 1;
                                  final instruction = entry.value;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$stepNumber. ',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Expanded(
                                          child: Text(instruction),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: exercise.mediaPaths.map((path) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        path,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          height: 200,
                                          color: Colors.black12,
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (widget.selectable) ...[
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, exercise),
                                  child: const Text('Select'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
