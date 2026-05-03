import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:auksine_bycke/database/database_helper.dart';
import 'package:auksine_bycke/workouts/workout_models.dart';
import 'package:auksine_bycke/pages/workout_summary_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, WorkoutModel> _workoutByDay = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final all = await DatabaseHelper.instance.getAllWorkouts();
    final completed = all.where((w) => !w.name.startsWith('[ROUTINE]'));
    setState(() {
      _workoutByDay = {
        for (final w in completed) _normalise(w.date): w,
      };
      _isLoading = false;
    });
  }

  DateTime _normalise(DateTime d) => DateTime(d.year, d.month, d.day);

  WorkoutModel? _workoutFor(DateTime day) =>
      _workoutByDay[_normalise(day)];

  bool _hasWorkout(DateTime day) => _workoutFor(day) != null;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    final workout = _workoutFor(selectedDay);
    if (workout != null) _showWorkoutSheet(workout);
  }

  void _showWorkoutSheet(WorkoutModel workout) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fitness_center,
                      color: Color(0xFFFFD700), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(workout.date),
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (workout.rating > 0)
                  Row(
                    children: List.generate(
                      workout.rating,
                      (_) => const Icon(Icons.star,
                          color: Colors.amber, size: 18),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats
            _InfoRow(
              icon: Icons.bar_chart,
              label: 'Exercises',
              value: '${workout.exercises.length}',
            ),
            _InfoRow(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: _formatDuration(workout.duration),
            ),
            _InfoRow(
              icon: Icons.fitness_center,
              label: 'Total volume',
              value: '${_totalVolume(workout).toStringAsFixed(1)} kg',
            ),
            if (workout.comment.isNotEmpty)
              _InfoRow(
                  icon: Icons.notes,
                  label: 'Note',
                  value: workout.comment),

            const SizedBox(height: 24),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutSummaryPage(
                        workout: workout,
                        personalRecords: const [],
                        onSave: () => Navigator.pop(context),
                      ),
                    ),
                  );
                },
                child: const Text('View Full Workout',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  double _totalVolume(WorkoutModel w) => w.exercises.fold(
      0.0,
      (sum, ex) =>
          sum + ex.sets.fold(0.0, (s, set) => s + set.reps * set.weight));

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.'
      '${d.year}';

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Calendar'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              onPageChanged: (focusedDay) =>
                  setState(() => _focusedDay = focusedDay),
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                    color: Color(0xFFFFD700), shape: BoxShape.circle),
                selectedTextStyle: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
                outsideDaysVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) {
                  if (_hasWorkout(day)) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Color(0xFFFFD700), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade500),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: Colors.grey.shade500)),
            const Spacer(),
            Flexible(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.end),
            ),
          ],
        ),
      );
}