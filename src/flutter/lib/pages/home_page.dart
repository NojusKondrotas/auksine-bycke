import 'package:auksine_bycke/pages/profile_page.dart';
import 'package:auksine_bycke/pages/progress_page.dart';
import 'package:auksine_bycke/pages/settings_page.dart';
import 'package:auksine_bycke/pages/workout_page.dart';
import 'package:auksine_bycke/utils/exercise_data.dart';
import 'package:auksine_bycke/utils/workout_tags/endurance_tag.dart';
import 'package:auksine_bycke/utils/workout_tags/fat_loss_tag.dart';
import 'package:auksine_bycke/utils/workout_tags/full_body_tag.dart';
import 'package:auksine_bycke/utils/workout_tags/lower_body_tag.dart';
import 'package:auksine_bycke/utils/workout_tags/muscle_tag.dart';
import 'package:auksine_bycke/utils/workout_tags/strength_tag.dart';
import 'package:auksine_bycke/utils/workout_tags/upper_body_tag.dart';
import 'package:auksine_bycke/widgets/workout_plan/workout.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const HomePage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  void navigateBottomBar(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
Widget build(BuildContext context) {
  final List<Widget> pages = [
    const HomeContentPage(),
    WorkoutPage(),
    ProgressPage(),
    ProfilePage(),
    SettingsPage(
      onThemeChanged: widget.onThemeChanged,
      isDarkMode: widget.isDarkMode,
    ),
  ];

  return Scaffold(
    appBar: AppBar(
      title: const Text("Auksinė byckė"),
      centerTitle: true,
    ),
    body: Column(
      children: [
        Expanded(
          child: pages[selectedIndex],
        ),
        if (selectedIndex == 0)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                navigateBottomBar(3);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Start Workout"),
            ),
          ),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      showUnselectedLabels: true,
      currentIndex: selectedIndex,
      onTap: navigateBottomBar,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progress"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    ),
  );
}
}

class HomeContentPage extends StatelessWidget {
  const HomeContentPage({super.key});

  @override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Welcome back",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: 500,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Workout(
                  name: "Today's Workout",
                  exercises: [
                    ExerciseData(name: 'Bench Press', sets: 4, reps: 5),
                    ExerciseData(name: 'Shoulder Press', sets: 4, reps: 10),
                    ExerciseData(name: 'Triceps', sets: 4, reps: 10),
                  ],
                  tags: [
                    EnduranceTag(),
                    FatLossTag(),
                    FullBodyTag(),
                    UpperBodyTag(),
                    LowerBodyTag(),
                    StrengthTag(),
                    MuscleTag(),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: 500,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Workout(
                  name: "Tomorrow's Workout",
                  exercises: [
                    ExerciseData(name: 'Biceps', sets: 4, reps: 10),
                    ExerciseData(name: 'Triceps', sets: 4, reps: 10),
                  ],
                  tags: [
                    UpperBodyTag(),
                    StrengthTag(),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: 500,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Workout(
                  name: "Marta's Workout",
                  exercises: [
                    ExerciseData(name: 'Biceps', sets: 4, reps: 12),
                    ExerciseData(name: 'Press', sets: 3, reps: 20),
                    ExerciseData(name: 'Dumbbells', sets: 4, reps: 10),
                  ],
                  tags: [
                    UpperBodyTag(),
                    StrengthTag(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}