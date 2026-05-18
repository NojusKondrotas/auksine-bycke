import 'dart:io';

import 'package:auksine_bycke/database/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  static Future<void> exportWorkouts() async {
    final workouts =
        await DatabaseHelper.instance.getAllWorkouts();

    final buffer = StringBuffer();

    // CSV HEADER
    buffer.writeln(
      'Date,Workout Name,Exercise,Sets,Reps,Weight,Duration',
    );

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        for (final set in exercise.sets) {
          buffer.writeln(
            '"${workout.date}",'
            '"${workout.name}",'
            '"${exercise.exerciseRefId}",'
            '"${exercise.sets.length}",'
            '"${set.reps}",'
            '"${set.weight}",'
            '"${workout.duration}"',
          );
        }
      }
    }

    final directory = await getTemporaryDirectory();

    final file = File(
      '${directory.path}/workout_export.csv',
    );

    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Workout history export',
    );
  }
}