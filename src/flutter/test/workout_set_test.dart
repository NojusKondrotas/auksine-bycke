// test/unit/workout_set_test.dart
//
// Unit tests for WorkoutSet — the chosen class for in-depth coverage.
// Demonstrates: setUp/tearDown, parametrized tests, stubs.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auksine_bycke/pages/workout_page.dart';
import 'package:auksine_bycke/utils/exercise_info.dart';

// ---------------------------------------------------------------------------
// STUB — minimal stand-in for ExerciseInfo, isolating WorkoutSet/Exercise
// from real catalog data.
// ---------------------------------------------------------------------------
ExerciseInfo stubExercise({
  String id = 'ex_001',
  String name = 'Bench Press',
}) =>
    ExerciseInfo(
      id: id,
      name: name,
      bodyParts: const ['Chest'],
      muscles: const ['Pectoralis Major'],
      instructions: const ['Lie on bench', 'Lower bar', 'Press up'],
      mediaPaths: const [],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // =========================================================================
  // 1. WorkoutSet — unit tests
  // =========================================================================
  group('WorkoutSet', () {
    late WorkoutSet sut;

    // setUp — runs before each test in this group
    setUp(() {
      sut = WorkoutSet(reps: 8, weight: 60.0);
    });

    // tearDown — disposes TextEditingControllers to prevent memory leaks
    tearDown(() {
      sut.dispose();
    });

    test('initialises reps correctly', () {
      expect(sut.reps, equals(8));
    });

    test('initialises weight correctly', () {
      expect(sut.weight, equals(60.0));
    });

    test('isCompleted defaults to false', () {
      expect(sut.isCompleted, isFalse);
    });

    test('repsController.text mirrors initial reps', () {
      expect(sut.repsController.text, equals('8'));
    });

    test('weightController.text mirrors initial weight', () {
      expect(sut.weightController.text, equals('60.0'));
    });

    test('reps field is mutable', () {
      sut.reps = 12;
      expect(sut.reps, equals(12));
    });

    test('weight field is mutable', () {
      sut.weight = 100.0;
      expect(sut.weight, equals(100.0));
    });

    test('isCompleted can be set to true', () {
      sut.isCompleted = true;
      expect(sut.isCompleted, isTrue);
    });

    // -----------------------------------------------------------------------
    // Parametrized tests — same assertion logic, varied inputs.
    // Dart has no @ParameterizedTest annotation; the idiomatic approach is
    // iterating over a structured list of test cases.
    // -----------------------------------------------------------------------
    group('parametrized initialisation', () {
      const cases = [
        (reps: 0,   weight: 0.0,   label: 'zero values'),
        (reps: 1,   weight: 2.5,   label: 'fractional weight'),
        (reps: 15,  weight: 80.0,  label: 'typical working set'),
        (reps: 50,  weight: 200.0, label: 'high-volume extreme'),
      ];

      for (final tc in cases) {
        test('${tc.label}: reps=${tc.reps}, weight=${tc.weight}', () {
          final ws = WorkoutSet(reps: tc.reps, weight: tc.weight);
          addTearDown(ws.dispose);

          expect(ws.reps,                 equals(tc.reps));
          expect(ws.weight,               equals(tc.weight));
          expect(ws.repsController.text,  equals(tc.reps.toString()));
          expect(ws.isCompleted,          isFalse);
        });
      }
    });
  });

  // =========================================================================
  // 2. Exercise (data model wrapper) — unit tests
  // =========================================================================
  group('Exercise model', () {
    late Exercise sut;

    setUp(() {
      sut = Exercise(
        exercise: stubExercise(),
        sets: [WorkoutSet(reps: 10, weight: 50.0)],
      );
    });

    tearDown(() {
      for (final s in sut.sets) {
        s.dispose();
      }
    });

    test('holds correct ExerciseInfo reference', () {
      expect(sut.exercise?.name, equals('Bench Press'));
    });

    test('holds initial sets', () {
      expect(sut.sets, hasLength(1));
    });

    test('exercise can be null (unselected state)', () {
      final unselected = Exercise(exercise: null, sets: []);
      expect(unselected.exercise, isNull);
    });

    group('parametrized set counts', () {
      for (final count in [0, 1, 3, 5]) {
        test('accepts $count sets', () {
          final sets = List.generate(
            count,
            (_) => WorkoutSet(reps: 10, weight: 40.0),
          );
          final ex = Exercise(exercise: stubExercise(), sets: sets);
          addTearDown(() { for (final s in ex.sets) s.dispose(); });

          expect(ex.sets, hasLength(count));
        });
      }
    });
  });
}
