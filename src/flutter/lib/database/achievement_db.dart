import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final bool isUnlocked;
  final DateTime? unlockDate;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.isUnlocked = false,
    this.unlockDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_name': iconName,
      'is_unlocked': isUnlocked ? 1 : 0,
      'unlock_date': unlockDate?.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      iconName: map['icon_name'],
      isUnlocked: map['is_unlocked'] == 1,
      unlockDate: map['unlock_date'] != null
          ? DateTime.parse(map['unlock_date'])
          : null,
    );
  }
}

class AchievementDatabase {
  static final AchievementDatabase instance = AchievementDatabase._init();
  static Database? _database;

  AchievementDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('achievements.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        icon_name TEXT,
        is_unlocked INTEGER NOT NULL,
        unlock_date TEXT
      )
    ''');

    final initialBadges = [
      Achievement(
        id: 'first_workout',
        title: 'First Steps',
        description: 'Complete your first workout.',
        iconName: 'fitness_center',
      ),
      Achievement(
        id: 'ten_workouts',
        title: 'Consistency',
        description: 'Complete 10 workouts.',
        iconName: 'repeat',
      ),
      Achievement(
        id: 'heavy_lifter',
        title: 'Heavy Lifter',
        description: 'Lift 100kg or more in any exercise.',
        iconName: 'fitness_center',
      ),
    ];

    for (var badge in initialBadges) {
      await db.insert('achievements', badge.toMap());
    }
  }

  Future<List<Achievement>> getAllAchievements() async {
    final db = await instance.database;
    final maps = await db.query('achievements');
    return maps.map((map) => Achievement.fromMap(map)).toList();
  }

  Future<void> unlockAchievement(String id) async {
    final db = await instance.database;
    await db.update(
      'achievements',
      {'is_unlocked': 1, 'unlock_date': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
