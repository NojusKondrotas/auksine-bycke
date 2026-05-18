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
      version: 5,
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
        await db.execute('''
          CREATE TABLE personal_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            exercise_ref_id TEXT,
            weight REAL,
            reps INTEGER,
            date TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE workout_plans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            planned_date TEXT NOT NULL,
            routine_id INTEGER NOT NULL,
            routine_name TEXT NOT NULL,
            FOREIGN KEY (routine_id) REFERENCES workouts(id)
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
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE personal_records (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              exercise_ref_id TEXT,
              weight REAL,
              reps INTEGER,
              date TEXT
            )
          ''');
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS workout_plans (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              planned_date TEXT NOT NULL,
              routine_id INTEGER NOT NULL,
              routine_name TEXT NOT NULL,
              FOREIGN KEY (routine_id) REFERENCES workouts(id)
            )
          ''');
        }
      },
    );
  }

  // ================= EXERCISE INFO =================
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
      muscles: [],
      bodyParts: [],
      instructions: [],
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

  // ================= GET ALL WORKOUTS (optimized) =================
  Future<List<WorkoutModel>> getAllWorkouts() async {
    final db = await database;

    // Single JOIN query instead of N+1 loop
    final rows = await db.rawQuery('''
      SELECT
        w.id        AS w_id,
        w.name      AS w_name,
        w.duration  AS w_duration,
        w.date      AS w_date,
        w.rating    AS w_rating,
        w.comment   AS w_comment,
        e.id        AS e_id,
        e.exercise_ref_id AS e_ref,
        s.id        AS s_id,
        s.reps      AS s_reps,
        s.weight    AS s_weight
      FROM workouts w
      LEFT JOIN exercises e ON e.workout_id = w.id
      LEFT JOIN sets s ON s.exercise_id = e.id
      ORDER BY w.date DESC, w.id, e.id, s.id
    ''');

    // Build WorkoutModel map from flat rows
    final Map<int, WorkoutModel> workoutMap = {};
    final Map<int, ExerciseModel> exerciseMap = {};

    for (final row in rows) {
      final wId = row['w_id'] as int;

      // Add workout if not seen yet
      if (!workoutMap.containsKey(wId)) {
        workoutMap[wId] = WorkoutModel(
          id: wId,
          name: row['w_name'] as String,
          duration: row['w_duration'] as int,
          date: DateTime.parse(row['w_date'] as String),
          rating: row['w_rating'] as int? ?? 0,
          comment: row['w_comment'] as String? ?? '',
          exercises: [],
        );
      }

      final eId = row['e_id'] as int?;
      if (eId == null) continue; // workout with no exercises

      // Add exercise if not seen yet
      if (!exerciseMap.containsKey(eId)) {
        final exercise = ExerciseModel(
          id: eId,
          workoutId: wId,
          exerciseRefId: (row['e_ref'] as String?) ?? '',
          sets: [],
        );
        exerciseMap[eId] = exercise;
        workoutMap[wId]!.exercises.add(exercise);
      }

      final sId = row['s_id'] as int?;
      if (sId == null) continue; // exercise with no sets

      exerciseMap[eId]!.sets.add(SetModel(
        id: sId,
        exerciseId: eId,
        reps: row['s_reps'] as int,
        weight: (row['s_weight'] as num).toDouble(),
      ));
    }

    return workoutMap.values.toList();
  }

  // ================= PR METHODS =================

  Future<double> getMaxPRWeight(String exerciseRefId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT MAX(weight) as max_weight
      FROM personal_records
      WHERE exercise_ref_id = ?
    ''', [exerciseRefId]);
    if (result.isEmpty || result.first['max_weight'] == null) return 0;
    return (result.first['max_weight'] as num).toDouble();
  }

  Future<void> insertPR(String exerciseRefId, double weight, int reps) async {
    final db = await database;
    await db.insert('personal_records', {
      'exercise_ref_id': exerciseRefId,
      'weight': weight,
      'reps': reps,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllPRs() async {
    final db = await database;
    return await db.query('personal_records', orderBy: 'date DESC');
  }

  // ================= HELPER METHODS =================

  Future<List<String>> getExerciseReferenceIds() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT DISTINCT exercise_ref_id FROM exercises WHERE exercise_ref_id IS NOT NULL ORDER BY exercise_ref_id ASC',
    );
    return rows.map((r) => r['exercise_ref_id'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getExerciseProgress(
      String exerciseRefId) async {
    final db = await database;
    return await db.rawQuery('''
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
    ''', [exerciseRefId]);
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

  Future<int> getMaxRepsForExercise(String exerciseRefId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT MAX(s.reps) as max_reps
      FROM sets s
      JOIN exercises e ON s.exercise_id = e.id
      WHERE e.exercise_ref_id = ?
    ''', [exerciseRefId]);
    if (result.isEmpty || result.first['max_reps'] == null) return 0;
    return (result.first['max_reps'] as int?) ?? 0;
  }

  Future<bool> isWeightPR(String exerciseRefId, double weight) async {
    final maxWeight = await getMaxWeightForExercise(exerciseRefId);
    return weight > maxWeight;
  }

  Future<bool> isRepsPR(String exerciseRefId, int reps) async {
    final maxReps = await getMaxRepsForExercise(exerciseRefId);
    return reps > maxReps;
  }

  Future<void> updatePRsForWorkout(
      String exerciseRefId, List<SetModel> sets) async {
    for (final set in sets) {
      final weightPR = await isWeightPR(exerciseRefId, set.weight);
      final repsPR = await isRepsPR(exerciseRefId, set.reps);
      if (weightPR || repsPR) {
        await insertPR(exerciseRefId, set.weight, set.reps);
      }
    }
  }

  Future<int> getWorkoutStreak() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT date FROM workouts ORDER BY date DESC
    ''');
    if (result.isEmpty) return 0;

    final dates = result.map((row) {
      final d = DateTime.parse(row['date'] as String);
      return DateTime(d.year, d.month, d.day);
    }).toSet().toList();

    dates.sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime currentDay = DateTime(today.year, today.month, today.day);

    for (final date in dates) {
      final diff = currentDay.difference(date).inDays;
      if (diff == 0 || diff == 1) {
        streak++;
        currentDay = currentDay.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // ================= WORKOUT PLANS =================

  Future<void> savePlan({
    required DateTime plannedDate,
    required int routineId,
    required String routineName,
  }) async {
    final db = await database;
    await db.insert('workout_plans', {
      'planned_date': DateTime(
          plannedDate.year, plannedDate.month, plannedDate.day)
          .toIso8601String(),
      'routine_id': routineId,
      'routine_name': routineName,
    });
  }

  Future<Map<DateTime, Map<String, dynamic>>> getAllPlans() async {
    final db = await database;
    final rows =
    await db.query('workout_plans', orderBy: 'planned_date ASC');
    return {
      for (final r in rows)
        DateTime.parse(r['planned_date'] as String): r,
    };
  }

  Future<void> deletePlan(int planId) async {
    final db = await database;
    await db.delete('workout_plans', where: 'id = ?', whereArgs: [planId]);
  }

  Future<void> deletePlanByDate(DateTime date) async {
    final db = await database;
    final normalised =
    DateTime(date.year, date.month, date.day).toIso8601String();
    await db.delete(
      'workout_plans',
      where: 'planned_date = ?',
      whereArgs: [normalised],
    );
  }
}