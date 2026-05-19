import 'package:flutter/material.dart';
import 'package:auksine_bycke/utils/exercise_catalog.dart';
import 'package:auksine_bycke/utils/exercise_info.dart';

class ExerciseBrowserPage extends StatefulWidget {
  const ExerciseBrowserPage({super.key});

  @override
  State<ExerciseBrowserPage> createState() =>
      _ExerciseBrowserPageState();
}

class _ExerciseBrowserPageState
    extends State<ExerciseBrowserPage> {

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
        for (final e in predefinedExercises)
          ...e.muscles,
      }
    ];

    bodyParts = [
      'All',
      ...{
        for (final e in predefinedExercises)
          ...e.bodyParts,
      }
    ];
  }

  List<ExerciseInfo> get filteredExercises {
    return predefinedExercises.where((exercise) {
      final matchesSearch =
          exercise.name.toLowerCase().contains(
                search.toLowerCase(),
              );

      final matchesMuscle =
          selectedMuscle == 'All' ||
              exercise.muscles.contains(selectedMuscle);

      final matchesBodyPart =
          selectedBodyPart == 'All' ||
              exercise.bodyParts.contains(selectedBodyPart);

      return matchesSearch &&
          matchesMuscle &&
          matchesBodyPart;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Exercise Browser'),
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(60),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search exercise...',
          prefixIcon: Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            search = value;
          });
        },
      ),
    ),
  ),
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
                    items: muscles.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(m),
                      );
                    }).toList(),
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
                    items: bodyParts.map((b) {
                      return DropdownMenuItem(
                        value: b,
                        child: Text(b),
                      );
                    }).toList(),
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

                final exercise =
                    filteredExercises[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(

                    leading: const Icon(
                      Icons.fitness_center,
                    ),

                    title: Text(exercise.name),

                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          'Muscles: ${exercise.muscles.join(', ')}',
                        ),

                        Text(
                          'Body Parts: ${exercise.bodyParts.join(', ')}',
                        ),
                      ],
                    ),

                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),

                    onTap: () {
                      Navigator.pop(
                        context,
                        exercise,
                      );
                    },
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