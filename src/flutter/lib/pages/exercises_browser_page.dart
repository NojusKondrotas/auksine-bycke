import 'package:flutter/material.dart';
import 'package:auksine_bycke/utils/exercise_catalog.dart';
import 'package:auksine_bycke/utils/exercise_info.dart';

class ExerciseBrowserPage extends StatefulWidget {
  final bool selectable;

  const ExerciseBrowserPage({
    super.key,
    this.selectable = true,
  });

  @override
  State<ExerciseBrowserPage> createState() => _ExerciseBrowserPageState();
}

class _ExerciseBrowserPageState extends State<ExerciseBrowserPage> {
  String search = '';
  String selectedMuscle = 'All';
  String selectedBodyPart = 'All';

  late List<String> muscles;
  late List<String> bodyParts;

  @override
  void initState() {
    super.initState();

    muscles = [
      'All',
      ...{
        for (final e in predefinedExercises) ...e.muscles,
      }
    ];

    bodyParts = [
      'All',
      ...{
        for (final e in predefinedExercises) ...e.bodyParts,
      }
    ];
  }

  List<ExerciseInfo> get filteredExercises {
    return predefinedExercises.where((exercise) {
      final matchesSearch =
          exercise.name.toLowerCase().contains(search.toLowerCase());

      final matchesMuscle = selectedMuscle == 'All' ||
          exercise.muscles.contains(selectedMuscle);

      final matchesBodyPart = selectedBodyPart == 'All' ||
          exercise.bodyParts.contains(selectedBodyPart);

      return matchesSearch && matchesMuscle && matchesBodyPart;
    }).toList();
  }

  void _openPreview(ExerciseInfo exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text('Muscles: ${exercise.muscles.join(', ')}'),
                  Text('Body parts: ${exercise.bodyParts.join(', ')}'),

                  const SizedBox(height: 16),

                  const Text(
                    'Instructions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  ...exercise.instructions.map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $i'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Demo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  ...exercise.mediaPaths.map(
                    (path) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Image.asset(path),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Browser'),
      ),

      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search exercise...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
            ),
          ),

          // FILTERS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMuscle,
                    decoration: const InputDecoration(
                      labelText: 'Muscle',
                      border: OutlineInputBorder(),
                    ),
                    items: muscles
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(m),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMuscle = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedBodyPart,
                    decoration: const InputDecoration(
                      labelText: 'Body Part',
                      border: OutlineInputBorder(),
                    ),
                    items: bodyParts
                        .map(
                          (b) => DropdownMenuItem(
                            value: b,
                            child: Text(b),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBodyPart = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // LIST
          Expanded(
            child: ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.fitness_center),

                  title: Text(exercise.name),

                  subtitle: Text(
                    'Muscles: ${exercise.muscles.join(', ')}\n'
                    'Body parts: ${exercise.bodyParts.join(', ')}',
                  ),

                onTap: () {
                  Navigator.pop(context, exercise);
                },

                trailing: IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  _openPreview(exercise);
                },
                ),
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}