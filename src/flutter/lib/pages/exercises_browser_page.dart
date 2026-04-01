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
                  subtitle: Text(exercise.shortDescription),
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
                              Text(exercise.fullDescription),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
