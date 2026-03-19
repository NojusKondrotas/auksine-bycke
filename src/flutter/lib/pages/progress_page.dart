import 'package:flutter/material.dart';
import 'package:auksine_bycke/database/database_helper.dart';
import 'package:auksine_bycke/workouts/workout_models.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  late Future<List<WorkoutModel>> _workoutsFuture;

  @override
  void initState() {
    super.initState();
    _workoutsFuture = DatabaseHelper.instance.getAllWorkouts();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: FutureBuilder<List<WorkoutModel>>(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No workouts are currently saved.'),
            );
          }

          final workouts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final w = workouts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ExpansionTile(
                  iconColor: theme.colorScheme.primary,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          w.name.isEmpty ? 'Unnamed Workout' : w.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (w.rating > 0) _buildRatingStars(w.rating),
                    ],
                  ),
                  subtitle: Text(
                    '${_formatDate(w.date)}  •  ${_formatDuration(w.duration)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  children: [
                    if (w.comment.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Feedback:",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '"${w.comment}"',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ...w.exercises.map((exercise) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name.isEmpty
                                  ? 'Unnamed Exercise'
                                  : exercise.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ...exercise.sets.asMap().entries.map((entry) {
                              final i = entry.key + 1;
                              final s = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  bottom: 2,
                                ),
                                child: Text(
                                  'Set $i: ${s.reps} reps × ${s.weight} kg',
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            }),
                            const Divider(),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
