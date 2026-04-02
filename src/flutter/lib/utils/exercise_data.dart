import 'package:auksine_bycke/utils/exercise_info.dart';

class ExerciseData {
  final ExerciseInfo exercise;
  final int sets;
  final int reps;

  String get name => exercise.name;

  const ExerciseData({
    required this.exercise,
    required this.sets,
    required this.reps,
  });
}
