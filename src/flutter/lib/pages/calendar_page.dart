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
  Map<DateTime, Map<String, dynamic>> _planByDay = {};
  bool _isLoading = true;

  // Colours
  static const _gold = Color(0xFFFFD700);
  static const _blue = Colors.blueAccent;
  static const _orange = Colors.deepOrange;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final all = await DatabaseHelper.instance.getAllWorkouts();
    final completed = all.where((w) => !w.name.startsWith('[ROUTINE]'));
    final plans = await DatabaseHelper.instance.getAllPlans();

    setState(() {
      _workoutByDay = {
        for (final w in completed) _normalise(w.date): w,
      };
      _planByDay = plans;
      _isLoading = false;
    });
  }

  DateTime _normalise(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime get _today => _normalise(DateTime.now());

  WorkoutModel? _workoutFor(DateTime day) => _workoutByDay[_normalise(day)];
  Map<String, dynamic>? _planFor(DateTime day) => _planByDay[_normalise(day)];

  bool _hasWorkout(DateTime day) => _workoutFor(day) != null;
  bool _hasPlan(DateTime day) => _planFor(day) != null;
  bool _isFuture(DateTime day) => _normalise(day).isAfter(_today);

  /// Past day that had a plan but no workout recorded
  bool _isMissed(DateTime day) {
    final n = _normalise(day);
    return n.isBefore(_today) && _hasPlan(day) && !_hasWorkout(day);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final workout = _workoutFor(selectedDay);
    if (workout != null) {
      _showWorkoutSheet(workout);
      return;
    }

    if (_isMissed(selectedDay)) {
      _showMissedDialog(selectedDay);
      return;
    }

    if (_isFuture(selectedDay)) {
      _showPlanDialog(selectedDay);
    }
  }

  // ── Missed day dialog ─────────────────────────────────────────────────────

  void _showMissedDialog(DateTime day) {
    final plan = _planFor(day)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Missed workout'),
        content: Text(
          'You planned "${plan['routine_name']}" for ${_formatDate(day)} but did not complete it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.instance.deletePlanByDate(day);
              await _loadData();
            },
            child: const Text('Remove plan'),
          ),
        ],
      ),
    );
  }

  // ── Plan dialog ───────────────────────────────────────────────────────────

  Future<void> _showPlanDialog(DateTime day) async {
    final all = await DatabaseHelper.instance.getAllWorkouts();
    final routines = all.where((w) => w.name.startsWith('[ROUTINE]')).toList();

    if (!mounted) return;

    if (routines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No routines found. Create a routine first.')),
      );
      return;
    }

    final existing = _planFor(day);
    if (existing != null) {
      _showRemovePlanDialog(day, existing);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Plan workout for ${_formatDate(day)}',
          style: const TextStyle(fontSize: 16),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final r = routines[index];
              final name = r.name.replaceFirst('[ROUTINE] ', '');
              return ListTile(
                leading:
                const Icon(Icons.fitness_center, color: _gold),
                title: Text(name),
                subtitle: Text('${r.exercises.length} exercises'),
                onTap: () async {
                  Navigator.pop(context);
                  await DatabaseHelper.instance.savePlan(
                    plannedDate: day,
                    routineId: r.id!,
                    routineName: name,
                  );
                  await _loadData();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '$name planned for ${_formatDate(day)}')),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRemovePlanDialog(
      DateTime day, Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove plan?'),
        content: Text(
            '${plan['routine_name']} is already planned for ${_formatDate(day)}. Remove it?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.instance
                  .deletePlan(plan['id'] as int);
              await _loadData();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  // ── Workout bottom sheet ──────────────────────────────────────────────────

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fitness_center,
                      color: _gold, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(workout.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(_formatDate(workout.date),
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 13)),
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
            _InfoRow(
                icon: Icons.bar_chart,
                label: 'Exercises',
                value: '${workout.exercises.length}'),
            _InfoRow(
                icon: Icons.timer_outlined,
                label: 'Duration',
                value: _formatDuration(workout.duration)),
            _InfoRow(
                icon: Icons.fitness_center,
                label: 'Total volume',
                value: '${_totalVolume(workout).toStringAsFixed(1)} kg'),
            if (workout.comment.isNotEmpty)
              _InfoRow(
                  icon: Icons.notes,
                  label: 'Note',
                  value: workout.comment),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
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

  int _workoutsThisMonth() => _workoutByDay.keys
      .where((d) =>
  d.year == _focusedDay.year && d.month == _focusedDay.month)
      .length;

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final daysInMonth =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final trainedCount = _workoutsThisMonth();
    final percent = trainedCount == 0
        ? 0
        : (trainedCount / daysInMonth * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Calendar'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Calendar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay:
                    DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day),
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
                        color: _gold.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                          color: _gold, shape: BoxShape.circle),
                      selectedTextStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      outsideDaysVisible: false,
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, _) {
                        if (_hasWorkout(day)) {
                          return _DayCell(day: day, color: _gold, textColor: Colors.black);
                        }
                        if (_isMissed(day)) {
                          return _DayCell(day: day, color: _orange, textColor: Colors.white);
                        }
                        if (_hasPlan(day)) {
                          return _DayCell(day: day, color: _blue, textColor: Colors.white);
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Legend ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _LegendDot(color: _gold),
                  const SizedBox(width: 4),
                  const Text('Done'),
                  const SizedBox(width: 12),
                  _LegendDot(color: _blue),
                  const SizedBox(width: 4),
                  const Text('Planned'),
                  const SizedBox(width: 12),
                  _LegendDot(color: _orange),
                  const SizedBox(width: 4),
                  const Text('Missed'),
                  const Spacer(),
                  _LegendDot(color: _gold.withOpacity(0.4)),
                  const SizedBox(width: 4),
                  const Text('Today'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Monthly summary ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month,
                          color: _gold, size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('This month',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '$trainedCount / $daysInMonth days trained',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: _gold),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Reusable day cell ─────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime day;
  final Color color;
  final Color textColor;
  const _DayCell(
      {required this.day, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    alignment: Alignment.center,
    child: Text(
      '${day.day}',
      style: TextStyle(
          color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
    ),
  );
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

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