import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Function(String?)? onNotificationTap;

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    tz.setLocalLocation(tz.getLocation('Europe/Vilnius'));

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
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
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> showInstantTestNotification() async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'workout_channel',
        'Workout Notifications',
        channelDescription: 'Daily workout reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      999,
      "Today's Workout 💪",
      "Bench Press, Shoulder Press, Triceps",
      notificationDetails,
      payload: 'workout_page',
    );
  }

  static Future<bool> checkPermissions() async {
    if (await _notifications
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    ) ??
        false) {
      return true;
    }

    if (await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission() ??
        false) {
      return true;
    }

    return false;
  }

  static Future<void> testForegroundNotification() async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Testing notification delivery',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      1001,
      "✅ Foreground Test",
      "This notification was sent while app is in foreground",
      notificationDetails,
      payload: 'home',
    );
  }

  static Future<void> testBackgroundNotification() async {
    final scheduledTime =
    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Testing notification delivery',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      1002,
      "🔔 Background Test",
      "This notification was scheduled for background/terminated state (5s delay)",
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'progress',
    );
  }

  static Future<void> testNavigationNotification() async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Testing notification delivery',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      1003,
      "🎯 Navigation Test",
      "Tap this notification to navigate to Workouts page",
      notificationDetails,
      payload: 'workout_page',
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

  // ================= WORKOUT PLAN REMINDERS =================

  /// Schedule a notification at 8:00 AM on [plannedDate].
  static Future<void> scheduleWorkoutReminder({
    required int id,
    required String routineName,
    required DateTime plannedDate,
  }) async {

    final now = tz.TZDateTime.now(tz.local);

    final scheduledDate = tz.TZDateTime(
      tz.local,
      plannedDate.year,
      plannedDate.month,
      plannedDate.day,
      8,
      0,
    );

    print('NOW: $now');
    print('SCHEDULED: $scheduledDate');
    if (scheduledDate.isBefore(now)) {
      print('SKIPPED: past date');
      return;
    }

    await _notifications.zonedSchedule(
      id,
      '💪 Workout day!',
      '$routineName is planned for today. Let\'s go!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_reminders',
          'Workout Reminders',
          channelDescription: 'Reminders for planned workouts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'calendar',
    );
  }

  /// Cancel a scheduled workout plan notification by [id].
  static Future<void> cancelWorkoutReminder(int id) async {
    await _notifications.cancel(id);
  }

  /// Generate a stable notification ID from a date (max 100000).
  static int idFromDate(DateTime date) =>
      int.parse(
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
      ) %
          100000;
}