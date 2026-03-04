import 'package:flutter/material.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  void _showCalculator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const OneRepMaxSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Your progress will be displayed here!"),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showCalculator(context),
              icon: const Icon(Icons.calculate),
              label: const Text("Calculate One Rep Max"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OneRepMaxSheet extends StatefulWidget {
  const OneRepMaxSheet({super.key});

  @override
  State<OneRepMaxSheet> createState() => _OneRepMaxSheetState();
}

class _OneRepMaxSheetState extends State<OneRepMaxSheet> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  String _result = "Enter details";

  void _calculate() {
    double weight = double.tryParse(_weightController.text) ?? 0;
    int reps = int.tryParse(_repsController.text) ?? 0;

    if (weight > 0 && reps > 0) {
      // Brzycki formula
      double max = weight * (36/(37-reps));
      setState(() {
        _result = "Estimated 1 Rep Max: ${max.toStringAsFixed(1)}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _result,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Weight lifted per rep",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _repsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Total reps performed",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _calculate, child: const Text("Calculate")),
        ],
      ),
    );
  }
}
