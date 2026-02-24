import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:auksine_bycke/workouts/workout_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'workouts.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE workouts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            duration INTEGER,
            date TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE exercises (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            workout_id INTEGER,
            name TEXT,
            FOREIGN KEY (workout_id) REFERENCES workouts(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE sets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            exercise_id INTEGER,
            reps INTEGER,
            weight REAL,
            FOREIGN KEY (exercise_id) REFERENCES exercises(id)
          )
        ''');
      },
    );
  }

  Future<void> saveWorkout(WorkoutModel workout) async {
    final db = await database;

    await db.transaction((txn) async {
      final workoutId = await txn.insert('workouts', {
        'name': workout.name,
        'duration': workout.duration,
        'date': workout.date.toIso8601String(),
      });

      for (final exercise in workout.exercises) {
        final exerciseId = await txn.insert('exercises', {
          'workout_id': workoutId,
          'name': exercise.name,
        });

        for (final set in exercise.sets) {
          await txn.insert('sets', {
            'exercise_id': exerciseId,
            'reps': set.reps,
            'weight': set.weight,
          });
        }
      }
    });
  }

  Future<List<WorkoutModel>> getAllWorkouts() async {
    final db = await database;

    final workoutRows = await db.query('workouts', orderBy: 'date DESC');

    final List<WorkoutModel> workouts = [];

    for (final row in workoutRows) {
      final workoutId = row['id'] as int;

      final exerciseRows = await db.query(
        'exercises',
        where: 'workout_id = ?',
        whereArgs: [workoutId],
      );

      final List<ExerciseModel> exercises = [];

      for (final exRow in exerciseRows) {
        final exerciseId = exRow['id'] as int;

        final setRows = await db.query(
          'sets',
          where: 'exercise_id = ?',
          whereArgs: [exerciseId],
        );

        final sets = setRows
            .map((s) => SetModel(
                  id: s['id'] as int,
                  exerciseId: exerciseId,
                  reps: s['reps'] as int,
                  weight: s['weight'] as double,
                ))
            .toList();

        exercises.add(ExerciseModel(
          id: exerciseId,
          workoutId: workoutId,
          name: exRow['name'] as String,
          sets: sets,
        ));
      }

      workouts.add(WorkoutModel(
        id: workoutId,
        name: row['name'] as String,
        duration: row['duration'] as int,
        date: DateTime.parse(row['date'] as String),
        exercises: exercises,
      ));
    }

    return workouts;
  }
}