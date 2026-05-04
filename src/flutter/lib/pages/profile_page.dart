import 'package:auksine_bycke/utils/UnitSystem.dart';
import 'package:flutter/material.dart';
import 'package:auksine_bycke/pages/register_page.dart';
import 'package:auksine_bycke/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfilePage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const ProfilePage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _bicepsController = TextEditingController();
  String _gender = 'Male';
  bool _saved = false;
  double _bmiResult = 0;
  String _bmiCategory = "";
  List<WeightEntry> _weightHistory = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGender = prefs.getString('gender') ?? 'Male';
    const validGenders = ['Male', 'Female', 'Other'];
    final String? historyJson = prefs.getString('weight_history');

    setState(() {
      if (historyJson != null) {
        Iterable l = json.decode(historyJson);
        _weightHistory = List<WeightEntry>.from(
          l.map((model) => WeightEntry.fromJson(model)),
        );
        _weightHistory.sort((a, b) => a.date.compareTo(b.date));

        if (_weightHistory.isNotEmpty) {
          _weightController.text = _weightHistory.last.weight.toString();
        }
      }
      _heightController.text = prefs.getString('height') ?? '';
      _ageController.text = prefs.getString('age') ?? '';
      _bicepsController.text = prefs.getString('biceps') ?? '';
      _gender = validGenders.contains(savedGender) ? savedGender : 'Male';
    });
    _calculateBMI();
  }

  Future<void> _addWeightEntry() async {
    DateTime selectedDate = DateTime.now();
    final TextEditingController weightEntryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Weight"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightEntryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Weight (kg)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) selectedDate = date;
              },
              child: const Text("Select Date"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final double? w = double.tryParse(weightEntryController.text);
              if (w != null) {
                setState(() {
                  _weightHistory.add(
                    WeightEntry(weight: w, date: selectedDate),
                  );
                  _weightHistory.sort((a, b) => a.date.compareTo(b.date));
                  _weightController.text = w.toString(); // Update latest weight
                });
                await _saveWeightHistory();
                _calculateBMI();
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveWeightHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonHistory = json.encode(
      _weightHistory.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('weight_history', jsonHistory);
  }

  void _deleteEntry(int index) async {
    setState(() {
      _weightHistory.removeAt(index);
    });
    await _saveWeightHistory();
    _calculateBMI();
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weight', _weightController.text);
    await prefs.setString('height', _heightController.text);
    await prefs.setString('age', _ageController.text);
    await prefs.setString('biceps', _bicepsController.text);
    await prefs.setString('gender', _gender);

    _calculateBMI();
    
    setState(() => _saved = true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile saved!')));
  }

  void _calculateBMI() {
    final units = UnitSystemScope.of(context);
    final double? height = double.tryParse(_heightController.text);

    if (height == null || height <= 0) return;

    double? weight;

    if (_weightHistory.isNotEmpty) {
      _weightHistory.sort((a, b) => a.date.compareTo(b.date));

      weight = _weightHistory.last.weight;

      _weightController.text = weight.toString();
    } else {
      weight = double.tryParse(_weightController.text);
    }

    if (weight == null) return;

    final double weightAmount = units.isMetric ? weight : weight / 2.20462;
    final double heightAmount = units.isMetric ? height : height * 2.54;

    setState(() {
      _bmiResult = weightAmount / ((heightAmount / 100) * (heightAmount / 100));

      if (_bmiResult < 18.5) {
        _bmiCategory = "Underweight";
      } else if (_bmiResult < 25) {
        _bmiCategory = "Normal weight";
      } else if (_bmiResult < 30) {
        _bmiCategory = "Overweight";
      } else {
        _bmiCategory = "Obese";
      }
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _bicepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final units = UnitSystemScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    onThemeChanged: widget.onThemeChanged,
                    isDarkMode: widget.isDarkMode,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_bmiResult > 0)
              Card(
                color: Colors.blueAccent.withValues(alpha: 0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.blueAccent),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.speed,
                        size: 40,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your BMI: ${_bmiResult.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Category: $_bmiCategory',
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Body characteristics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              readOnly: true,
              onTap: _addWeightEntry,
              decoration: InputDecoration(
                labelText: 'Weight (${units.weightLabel()})',
                hintText: "Tap to log weight",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.monitor_weight),
                suffixIcon: const Icon(Icons.add_circle_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Height (${units.heightLabel()})',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.height),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bicepsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Bicep size (${units.heightLabel()})',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (val) => setState(() => _gender = val!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Save'),
              ),
            ),
            const SizedBox(height: 24),
            _buildWeightChart(context),
            const SizedBox(height: 24),
            const Text(
              'Weight Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),
            const Text(
              'History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _weightHistory.reversed.length,
              itemBuilder: (context, index) {
                final entry = _weightHistory.reversed.toList()[index];
                final actualIndex = _weightHistory.length - 1 - index;
                return ListTile(
                  title: Text("${entry.weight} ${units.weightLabel()}"),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(entry.date)),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _deleteEntry(actualIndex),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Register Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildWeightChart(BuildContext context) {
    final theme = Theme.of(context);
    final units = UnitSystemScope.of(context);

    List<FlSpot> spots = _weightHistory.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    if (spots.length < 2) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Weight Progress — add at least 2 entries for a chart.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weight (${units.weightLabel()})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    ),
                  ),
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
                        getTitlesWidget: (val, meta) => Text(
                          val.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (val, meta) {
                          final i = val.toInt();
                          if (val != val.roundToDouble() ||
                              i < 0 ||
                              i >= _weightHistory.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat(
                                'MM/dd',
                              ).format(_weightHistory[i].date),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blueAccent, // Matches your Profile buttons
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blueAccent.withValues(alpha: 0.1),
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
}

class WeightEntry {
  final double weight;
  final DateTime date;

  WeightEntry({required this.weight, required this.date});

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'date': date.toIso8601String(),
  };

  factory WeightEntry.fromJson(Map<String, dynamic> json) =>
      WeightEntry(weight: json['weight'], date: DateTime.parse(json['date']));
}
