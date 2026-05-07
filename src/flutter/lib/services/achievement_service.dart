import 'package:flutter/material.dart';
import 'package:auksine_bycke/database/achievement_db.dart';

class AchievementService {
  static Future<void> checkWorkoutMilestones(
    BuildContext context,
    int totalWorkoutsCompleted,
  ) async {
    final db = AchievementDatabase.instance;
    final allBadges = await db.getAllAchievements();

    if (totalWorkoutsCompleted >= 1 && _isLocked(allBadges, 'first_workout')) {
      await _unlockAndNotify(context, db, 'first_workout', 'First Steps');
    }

    if (totalWorkoutsCompleted >= 10 && _isLocked(allBadges, 'ten_workouts')) {
      await _unlockAndNotify(context, db, 'ten_workouts', 'Consistency Key');
    }
  }

  static Future<void> checkWeightMilestones(
    BuildContext context,
    double weightLogged,
  ) async {
    final db = AchievementDatabase.instance;
    final allBadges = await db.getAllAchievements();

    if (weightLogged >= 100 && _isLocked(allBadges, 'heavy_lifter')) {
      await _unlockAndNotify(context, db, 'heavy_lifter', 'Heavy Lifter');
    }
  }

  static bool _isLocked(List<Achievement> badges, String id) {
    try {
      final badge = badges.firstWhere((b) => b.id == id);
      return !badge.isUnlocked;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _unlockAndNotify(
    BuildContext context,
    AchievementDatabase db,
    String id,
    String title,
  ) async {
    await db.unlockAchievement(id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(child: Text('Achievement Unlocked: $title!')),
            ],
          ),
          backgroundColor: Colors.blueAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
