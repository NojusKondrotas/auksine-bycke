import 'package:auksine_bycke/utils/UnitSystem.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:auksine_bycke/database/database_helper.dart';
import 'package:auksine_bycke/utils/exercise_catalog.dart';
import 'package:auksine_bycke/utils/exercise_info.dart';
import 'package:auksine_bycke/workouts/workout_models.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<WorkoutModel>> _workoutsFuture;

  // Statistikos state
  List<ExerciseInfo> _exerciseOptions = [];
  String? _selectedExerciseRefId;
  List<Map<String, dynamic>> _progressData = [];
  bool _statsLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _workoutsFuture = DatabaseHelper.instance.getAllWorkouts();
    _loadExerciseOptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // helpers
  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}  '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        ),
      ),
    );
  }

  // stats
  Future<void> _loadExerciseOptions() async {
    final ids = await DatabaseHelper.instance.getExerciseReferenceIds();
    final options = ids.map(getExerciseById).whereType<ExerciseInfo>().toList();

    if (!mounted) return;
    setState(() {
      _exerciseOptions = options;
      if (options.isNotEmpty) {
        _selectedExerciseRefId = options.first.id;
        _loadProgress(options.first.id);
      }
    });
  }

  Future<void> _loadProgress(String exerciseRefId) async {
    setState(() => _statsLoading = true);
    final data = await DatabaseHelper.instance.getExerciseProgress(
      exerciseRefId,
    );
    if (!mounted) return;
    setState(() {
      _progressData = data;
      _statsLoading = false;
    });
  }

  List<FlSpot> _spots(String key) {
    return _progressData.asMap().entries.map((e) {
      final v = (e.value[key] as num?)?.toDouble() ?? 0;
      return FlSpot(e.key.toDouble(), v);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.show_chart), text: 'Statistics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildHistoryTab(theme), _buildStatsTab(theme)],
      ),
    );
  }

  // HISTORY TAB
  Widget _buildHistoryTab(ThemeData theme) {
    return FutureBuilder<List<WorkoutModel>>(
      future: _workoutsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No workouts are currently saved.'));
        }

        final workouts = snapshot.data!;
        final units = UnitSystemScope.of(context);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final w = workouts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ExpansionTile(
                iconColor: theme.colorScheme.primary,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        w.name.isEmpty ? 'Unnamed Workout' : w.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (w.rating > 0) _buildRatingStars(w.rating),
                  ],
                ),
                subtitle: Text(
                  '${_formatDate(w.date)}  •  ${_formatDuration(w.duration)}',
                  style: theme.textTheme.bodySmall,
                ),
                children: [
                  if (w.comment.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Feedback:",
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '"${w.comment}"',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ...w.exercises.map(
                    (exercise) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getExerciseById(exercise.exerciseRefId)?.name ??
                                'Unknown exercise',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          ...exercise.sets.asMap().entries.map((entry) {
                            final i = entry.key + 1;
                            final s = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                bottom: 2,
                              ),
                              child: Text(
                                'Set $i: ${s.reps} reps × ${s.weight} ${units.weightLabel()}',
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          }),
                          const Divider(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //  STATS TAB
  Widget _buildStatsTab(ThemeData theme) {
    final units = UnitSystemScope.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown filtras
          DropdownButtonFormField<String>(
            value: _selectedExerciseRefId,
            decoration: const InputDecoration(
              labelText: 'Select exercise',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.fitness_center),
            ),
            items: _exerciseOptions
                .map(
                  (exercise) => DropdownMenuItem(
                    value: exercise.id,
                    child: Text(exercise.name),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedExerciseRefId = val);
                _loadProgress(val);
              }
            },
          ),

          const SizedBox(height: 20),

          // Turinys
          if (_exerciseOptions.isEmpty)
            const Expanded(child: Center(child: Text('No exercises found.')))
          else if (_statsLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_progressData.isEmpty)
            const Expanded(
              child: Center(child: Text('No data for this exercise yet.')),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  // Summary kortelės
                  _buildSummaryRow(theme),

                  const SizedBox(height: 16),

                  // Max svoris grafkas
                  _buildChartCard(
                    theme: theme,
                    title: 'Max Weight (${units.weightLabel()})',
                    spots: _spots('max_weight'),
                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(height: 16),

                  //Tūris grafkas
                  _buildChartCard(
                    theme: theme,
                    title: 'Volume (${units.weightLabel()} × reps)',
                    spots: _spots('volume'),
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 16),

                  _buildSessionList(theme),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 3 summary kortelės viršuje
  Widget _buildSummaryRow(ThemeData theme) {
    final maxWeight = _progressData
        .map((r) => (r['max_weight'] as num?)?.toDouble() ?? 0)
        .fold(0.0, (a, b) => a > b ? a : b);

    final totalVolume = _progressData
        .map((r) => (r['volume'] as num?)?.toDouble() ?? 0)
        .fold(0.0, (a, b) => a + b);

    final sessions = _progressData.length;

    final units = UnitSystemScope.of(context);

    return Row(
      children: [
        _summaryCard(theme, 'Sessions', '$sessions', Icons.event_repeat),
        const SizedBox(width: 8),
        _summaryCard(
          theme,
          'Max Weight',
          '${maxWeight.toStringAsFixed(1)} ${units.weightLabel()}',
          Icons.emoji_events,
        ),
        const SizedBox(width: 8),
        _summaryCard(
          theme,
          'Total Volume',
          '${totalVolume.toStringAsFixed(0)} ${units.weightLabel()}',
          Icons.bar_chart,
        ),
      ],
    );
  }

  Widget _summaryCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required ThemeData theme,
    required String title,
    required List<FlSpot> spots,
    required Color color,
  }) {
    if (spots.length < 2) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '$title — need at least 2 sessions for a chart.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (val, meta) {
                          final i = val.toInt();
                          if (val != val.roundToDouble())
                            return const SizedBox();
                          if (i < 0 || i >= _progressData.length)
                            return const SizedBox();
                          final date = DateTime.parse(
                            _progressData[i]['date'] as String,
                          );
                          return Text(
                            DateFormat('MM/dd').format(date),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Workout history
  Widget _buildSessionList(ThemeData theme) {
    final units = UnitSystemScope.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ..._progressData.reversed.map((row) {
              final date = DateTime.parse(row['date'] as String);
              return ListTile(
                dense: true,
                leading: const Icon(Icons.fitness_center, size: 18),
                title: Text(row['workout_name'] as String),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(date)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${row['max_weight']} ${units.weightLabel()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${row['total_reps']} reps',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
