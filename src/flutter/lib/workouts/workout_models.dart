class WorkoutModel {
  final int? id;
  final String name;
  final int duration;
  final DateTime date;
  final List<ExerciseModel> exercises;

  WorkoutModel({
    this.id,
    required this.name,
    required this.duration,
    required this.date,
    required this.exercises,
  });
}

class ExerciseModel {
  final int? id;
  final int? workoutId;
  final String name;
  final List<SetModel> sets;

  ExerciseModel({
    this.id,
    this.workoutId,
    required this.name,
    required this.sets,
  });
}

class SetModel {
  final int? id;
  final int? exerciseId;
  final int reps;
  final double weight;

  SetModel({
    this.id,
    this.exerciseId,
    required this.reps,
    required this.weight,
  });
}