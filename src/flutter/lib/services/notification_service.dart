import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    // Request notification permission (Android 13+)
    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleDailyWorkout(String body) async {
    await _notifications.zonedSchedule(
      0,
      "Today's Workout 💪",
      body,
      _nextInstanceOfSixPM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_workout_channel',
          'Daily Workout',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelDailyWorkout() async {
    await _notifications.cancel(0);
  }

  static tz.TZDateTime _nextInstanceOfSixPM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, 18);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  static Future<void> showInstantTestNotification() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'workout_channel',
      'Workout Notifications',
      channelDescription: 'Daily workout reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notifications.show(
      999, // random ID
      "Today's Workout 💪",
      "Bench Press, Shoulder Press, Triceps",
      details,
    );
  }
}