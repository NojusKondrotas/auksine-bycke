import 'package:auksine_bycke/pages/home_page.dart';
import 'package:auksine_bycke/services/notification_service.dart';
import 'package:auksine_bycke/utils/UnitSystem.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  
  NotificationService.onNotificationTap = (String? payload) {
    if (payload != null && navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(
            onThemeChanged: (bool value) {},
            isDarkMode: false,
            initialPage: _getPageIndexFromPayload(payload),
          ),
        ),
      );
    }
  };

  runApp(
    UnitSystemScope(
      notifier: UnitSystemNotifier(),
      child: const MyApp(),
    ),
  );
}

int _getPageIndexFromPayload(String payload) {
  switch (payload) {
    case 'home':
      return 0;
    case 'workout_page':
      return 1;
    case 'progress':
      return 2;
    case 'profile':
      return 3;
    default:
      return 0;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Auksinė byckė',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: HomePage(
        onThemeChanged: toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}