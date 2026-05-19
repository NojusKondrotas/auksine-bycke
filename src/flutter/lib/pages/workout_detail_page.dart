import 'package:flutter/material.dart';
import 'package:auksine_bycke/workouts/workout_models.dart';
import 'package:auksine_bycke/utils/exercise_catalog.dart';

class WorkoutDetailPage extends StatelessWidget {
  final WorkoutModel workout;

  const WorkoutDetailPage({super.key, required this.workout});

  String get _formattedDuration {
    final m = (workout.duration ~/ 60).toString().padLeft(2, '0');
    final s = (workout.duration % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _formattedDate {
    final d = workout.date;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
           '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  int get _totalExercises => workout.exercises.length;

  int get _totalSets => workout.exercises.fold<int>(0, (sum, ex) => sum + ex.sets.length);

  int get _totalReps => workout.exercises.fold<int>(
        0, (sum, ex) => sum + ex.sets.fold<int>(0, (setSum, s) => setSum + s.reps));

  double get _totalVolume => workout.exercises.fold<double>(
        0, (sum, ex) => sum + ex.sets.fold<double>(0, (setSum, s) => setSum + (s.weight * s.reps)));

  String get _formattedVolume {
    if (_totalVolume % 1 == 0) {
      return _totalVolume.toInt().toString();
    }
    return _totalVolume.toStringAsFixed(1);
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(
                value, 
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Text(_formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 18, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Text(_formattedDuration, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  if (workout.rating > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text("Rating: ", style: TextStyle(fontWeight: FontWeight.w500)),
                        ...List.generate(5, (index) {
                          return Icon(
                            index < workout.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20
                          );
                        }),
                      ],
                    ),
                  ],
                  if (workout.comment.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      "Notes: ${workout.comment}", 
                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildStatItem("Volume", "$_formattedVolume kg", Icons.fitness_center)),
                          Expanded(child: _buildStatItem("Exercises", "$_totalExercises", Icons.format_list_bulleted)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildStatItem("Sets", "$_totalSets", Icons.layers)),
                          Expanded(child: _buildStatItem("Reps", "$_totalReps", Icons.content_paste_go)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Exercises", 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...workout.exercises.map((exerciseModel) {
            final exerciseInfo = getExerciseById(exerciseModel.exerciseRefId);
            final exerciseName = exerciseInfo?.name ?? 'Unknown Exercise';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    ...exerciseModel.sets.asMap().entries.map((entry) {
                      final setIndex = entry.key + 1;
                      final setInfo = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Set $setIndex", 
                              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                            ),
                            Text(
                              "${setInfo.reps} reps × ${setInfo.weight} kg",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}