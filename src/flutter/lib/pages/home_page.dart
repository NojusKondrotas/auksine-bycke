import 'package:auksine_bycke/pages/profile_page.dart';
import 'package:auksine_bycke/pages/progress_page.dart';
import 'package:auksine_bycke/pages/workout_page.dart';
import 'package:auksine_bycke/utils/exercise_data.dart';
import 'package:auksine_bycke/widgets/workout_plan/workout.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  final List<Widget> pages = [HomeContentPage(), WorkoutPage(), ProgressPage(), ProfilePage()];

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Auksinė byckė"),
      centerTitle: true,
    ),
    body: Column(
      children: [
        Expanded(
          child: pages[selectedIndex], // tavo puslapio turinys
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              navigateBottomBar(1); //goes to WorkoutPage()
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
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progress"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    ),
  );
}

}

// Stateless widget only for home's content
class HomeContentPage extends StatelessWidget {
  const HomeContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Welcome back",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            width: 500,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Expanded(
                        child: Workout(
                          name: "Today's Workout",
                          exercises: [
                            ExerciseData(name: 'Bench Press', sets: 4, reps: 5),
                            ExerciseData(name: 'Shoulder Press', sets: 4, reps: 10),
                            ExerciseData(name: 'Triceps', sets: 4, reps: 10)
                          ],
                        ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
