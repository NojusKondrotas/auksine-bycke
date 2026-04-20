import 'package:flutter/material.dart';
import 'package:auksine_bycke/workouts/workout_models.dart';
import 'package:auksine_bycke/utils/exercise_catalog.dart';

class WorkoutSummaryPage extends StatelessWidget {
  final WorkoutModel workout;
  final List<String> personalRecords;
  final VoidCallback onSave;

  const WorkoutSummaryPage({
    super.key,
    required this.workout,
    required this.personalRecords,
    required this.onSave,
  });

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get totalVolume {
    double total = 0;
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        total += set.reps * set.weight;
      }
    }
    return total;
  }

  int get totalSets {
    return workout.exercises.fold(0, (sum, e) => sum + e.sets.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Summary'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
                  const SizedBox(height: 8),
                  Text(
                    workout.name.isEmpty ? 'Workout Complete!' : workout.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (workout.rating > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) => Icon(
                        i < workout.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 24,
                      )),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  icon: Icons.timer,
                  label: 'Duration',
                  value: _formatDuration(workout.duration),
                  color: Colors.blue,
                ),
                _StatCard(
                  icon: Icons.fitness_center,
                  label: 'Total Volume',
                  value: '${totalVolume.toStringAsFixed(1)} kg',
                  color: Colors.green,
                ),
                _StatCard(
                  icon: Icons.list,
                  label: 'Exercises',
                  value: '${workout.exercises.length}',
                  color: Colors.orange,
                ),
                _StatCard(
                  icon: Icons.repeat,
                  label: 'Total Sets',
                  value: '$totalSets',
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Personal records
            if (personalRecords.isNotEmpty) ...[
              const Text(
                '🏆 Personal Records!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...personalRecords.map((pr) => Card(
                color: Colors.amber.shade50,
                child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(pr),
                ),
              )),
              const SizedBox(height: 24),
            ],

            // Exercise breakdown
            const Text(
              'Exercise Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...workout.exercises.map((exercise) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getExerciseById(exercise.exerciseRefId)?.name ?? 'Unnamed Exercise',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    ...exercise.sets.asMap().entries.map((entry) {
                      final i = entry.key + 1;
                      final s = entry.value;
                      return Text('  Set $i: ${s.reps} reps × ${s.weight} kg');
                    }),
                  ],
                ),
              ),
            )),

            // Comment
            if (workout.comment.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(workout.comment),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  onSave();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Save & Go Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}