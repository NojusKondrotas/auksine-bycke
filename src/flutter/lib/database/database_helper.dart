import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:auksine_bycke/utils/exercise_catalog.dart';
import 'package:auksine_bycke/workouts/workout_models.dart';
import 'package:auksine_bycke/utils/exercise_info.dart';

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
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE workouts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            duration INTEGER,
            date TEXT,
            rating INTEGER,
            comment TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE exercises (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            workout_id INTEGER,
            exercise_ref_id TEXT,
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
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE workouts ADD COLUMN rating INTEGER');
          await db.execute('ALTER TABLE workouts ADD COLUMN comment TEXT');
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE exercises ADD COLUMN exercise_ref_id TEXT',
          );
        }
      },
    );
  }

  // ================= NEW METHOD =================
  Future<ExerciseInfo?> getExerciseInfoById(String id) async {
    final db = await database;
    final rows = await db.query(
      'exercises',
      where: 'exercise_ref_id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final row = rows.first;
    return ExerciseInfo(
      id: id,
      name: row['name'] as String? ?? 'Unknown Exercise',
      shortDescription: '',
      fullDescription: '',
      mediaPaths: [],
    );
  }

  // ================= SAVE WORKOUT =================
  Future<void> saveWorkout(WorkoutModel workout) async {
    final db = await database;

    await db.transaction((txn) async {
      final workoutId = await txn.insert('workouts', {
        'name': workout.name,
        'duration': workout.duration,
        'date': workout.date.toIso8601String(),
        'rating': workout.rating,
        'comment': workout.comment,
      });

      for (final exercise in workout.exercises) {
        final exerciseInfo = getExerciseById(exercise.exerciseRefId);
        final exerciseId = await txn.insert('exercises', {
          'workout_id': workoutId,
          'exercise_ref_id': exercise.exerciseRefId,
          'name': exerciseInfo?.name,
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

  // ================= GET ALL WORKOUTS =================
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
            .map(
              (s) => SetModel(
            id: s['id'] as int?,
            exerciseId: exerciseId,
            reps: s['reps'] as int,
            weight: (s['weight'] as num).toDouble(),
          ),
        )
            .toList();

        exercises.add(
          ExerciseModel(
            id: exerciseId,
            workoutId: workoutId,
            exerciseRefId:
            (exRow['exercise_ref_id'] as String?) ?? '',
            sets: sets,
          ),
        );
      }

      workouts.add(
        WorkoutModel(
          id: workoutId,
          name: row['name'] as String,
          duration: row['duration'] as int,
          date: DateTime.parse(row['date'] as String),
          rating: row['rating'] as int? ?? 0,
          comment: row['comment'] as String? ?? '',
          exercises: exercises,
        ),
      );
    }

    return workouts;
  }

  // ================= HELPER METHODS FOR PROGRESS =================
  Future<List<String>> getExerciseReferenceIds() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT DISTINCT exercise_ref_id FROM exercises WHERE exercise_ref_id IS NOT NULL ORDER BY exercise_ref_id ASC',
    );
    return rows.map((r) => r['exercise_ref_id'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getExerciseProgress(String exerciseRefId) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT
        w.date,
        w.name AS workout_name,
        MAX(s.weight) AS max_weight,
        SUM(s.reps) AS total_reps,
        SUM(s.reps * s.weight) AS volume
      FROM exercises e
      JOIN sets s ON s.exercise_id = e.id
      JOIN workouts w ON w.id = e.workout_id
      WHERE e.exercise_ref_id = ?
      GROUP BY w.id
      ORDER BY w.date ASC
      ''',
      [exerciseRefId],
    );
  }
  Future<double> getMaxWeightForExercise(String exerciseRefId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT MAX(s.weight) as max_weight
      FROM sets s
      JOIN exercises e ON s.exercise_id = e.id
      WHERE e.exercise_ref_id = ?
    ''', [exerciseRefId]);
    if (result.isEmpty || result.first['max_weight'] == null) return 0;
    return (result.first['max_weight'] as num).toDouble();
  }
}