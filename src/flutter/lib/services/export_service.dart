import 'dart:io';
import 'package:auksine_bycke/database/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  static Future<void> exportWorkouts() async {
    final workouts = await DatabaseHelper.instance.getAllWorkouts();

    final buffer = StringBuffer();

    buffer.writeln('Date,Workout Name,Exercise,Set No,Reps,Weight,Duration');

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        for (int i = 0; i < exercise.sets.length; i++) {
          final set = exercise.sets[i];

          buffer.writeln(
            '"${_formatDate(workout.date)}",'
            '"${workout.name}",'
            '"${exercise.exerciseRefId}",'
            '"${i + 1}",'
            '"${set.reps}",'
            '"${set.weight}",'
            '"${workout.duration}"',
          );
        }
      }
    }

    final directory = Directory('/storage/emulated/0/Download');

    final file = File('${directory.path}/workout_export.csv');

    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Workout history export',
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }
}