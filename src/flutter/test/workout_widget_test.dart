// test/widget/workout_widget_test.dart
//
// Widget tests for the `Workout` StatefulWidget — the chosen class.
// Covers: rendering, state mutations (addExercise / removeExercise /
// addTag / removeTag), tag deduplication via LinkedHashSet, and
// edge-cases (empty lists, duplicate tags).

import 'package:auksine_bycke/pages/workout_page.dart' hide Exercise;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auksine_bycke/widgets/workout_plan/workout.dart';     // Workout
import 'package:auksine_bycke/widgets/workout_plan/exercise.dart';    // Exercise
import 'package:auksine_bycke/utils/exercise_data.dart';
import 'package:auksine_bycke/utils/exercise_info.dart';
import 'package:auksine_bycke/utils/workout_tags/workout_tag.dart';

// ---------------------------------------------------------------------------
// STUBS
// ---------------------------------------------------------------------------

ExerciseInfo _info(String name) => ExerciseInfo(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      bodyParts: const [],
      muscles: const [],
      instructions: const [],
      mediaPaths: const [],
    );

ExerciseData _data(String name, {int sets = 3, int reps = 10}) =>
    ExerciseData(exercise: _info(name), sets: sets, reps: reps);

/// Minimal WorkoutTag stub — avoids depending on concrete tag implementations.
class _StubTag implements WorkoutTag {
  const _StubTag(this._label, this._color);
  final String _label;
  final Color _color;

  @override
  String getTag() => _label;

  @override
  Color getColor() => _color;

  @override
  bool operator ==(Object other) =>
      other is _StubTag && other._label == _label;

  @override
  int get hashCode => _label.hashCode;
}

const _strengthTag = _StubTag('Strength', Colors.red);
const _cardioTag   = _StubTag('Cardio',   Colors.blue);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps the widget under test in a MaterialApp for Theme/Navigator access.
Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

/// Finds the _WorkoutState via the Workout widget type.
/// Because _WorkoutState is private, we cast through the State interface and
/// call methods by name using the public API exposed on the state.
///
/// In practice, test access to state is through WidgetTester.state().
// ignore: library_private_types_in_public_api  (test-only usage)

void main() {
  // =========================================================================
  // 1. Rendering — no exercises, no tags
  // =========================================================================
  group('Workout renders', () {
    const workoutName = 'Push Day';
    late Widget sut;

    setUp(() {
      sut = _wrap(
        Workout(name: workoutName, exercises: [], tags: []),
      );
    });

    testWidgets('workout name is displayed', (tester) async {
      await tester.pumpWidget(sut);
      expect(find.text(workoutName), findsOneWidget);
    });

    testWidgets('tag section is absent when tags list is empty', (tester) async {
      await tester.pumpWidget(sut);
      // Wrap widget is present but no Chip should appear
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('no Exercise widgets when exercises list is empty',
        (tester) async {
      await tester.pumpWidget(sut);
      expect(find.byType(Exercise), findsNothing);
    });
  });

  // =========================================================================
  // 2. Rendering — with exercises
  // =========================================================================
  group('Workout with exercises', () {
    testWidgets('renders correct number of Exercise widgets', (tester) async {
      await tester.pumpWidget(_wrap(
        Workout(
          name: 'Leg Day',
          exercises: [_data('Squat'), _data('Leg Press'), _data('Leg Curl')],
        ),
      ));
      expect(find.byType(Exercise), findsNWidgets(3));
    });

    testWidgets('exercise names are visible', (tester) async {
      await tester.pumpWidget(_wrap(
        Workout(
          name: 'Pull Day',
          exercises: [_data('Deadlift'), _data('Row')],
        ),
      ));
      expect(find.text('Deadlift'), findsOneWidget);
      expect(find.text('Row'),      findsOneWidget);
    });

    testWidgets('sets×reps label is rendered for each exercise',
        (tester) async {
      await tester.pumpWidget(_wrap(
        Workout(
          name: 'W',
          exercises: [_data('Bench Press', sets: 4, reps: 6)],
        ),
      ));
      // Exercise widget renders "4 x 6"
      expect(find.text('4 x 6'), findsOneWidget);
    });

    // Parametrized: varying exercise counts
    for (final count in [1, 2, 5]) {
      testWidgets('renders $count exercises', (tester) async {
        final exercises = List.generate(count, (i) => _data('Ex $i'));
        await tester.pumpWidget(_wrap(Workout(name: 'W', exercises: exercises)));
        expect(find.byType(Exercise), findsNWidgets(count));
      });
    }
  });

  // =========================================================================
  // 3. Rendering — with tags
  // =========================================================================
  group('Workout with tags', () {
    testWidgets('renders a Chip for each tag', (tester) async {
      await tester.pumpWidget(_wrap(
        Workout(
          name: 'Full Body',
          tags: [_strengthTag, _cardioTag],
        ),
      ));
      expect(find.byType(Chip), findsNWidgets(2));
    });

    testWidgets('tag labels are displayed', (tester) async {
      await tester.pumpWidget(_wrap(
        Workout(name: 'W', tags: [_strengthTag]),
      ));
      expect(find.text('Strength'), findsOneWidget);
    });
  });

  // =========================================================================
  // 4. State mutations — addExercise / removeExercise
  // =========================================================================
  group('Workout state: addExercise', () {
    late GlobalKey<State> key;

    setUp(() {
      key = GlobalKey();
    });

    testWidgets('addExercise increases rendered Exercise count',
        (tester) async {
      await tester.pumpWidget(_wrap(
        Workout(key: key, name: 'W', exercises: [_data('Squat')]),
      ));
      expect(find.byType(Exercise), findsNWidgets(1));

      // Call addExercise on the live state
      final state = key.currentState!;
      // ignore: invalid_use_of_protected_member
      (state as dynamic).addExercise(_data('Bench Press'));
      await tester.pump();

      expect(find.byType(Exercise), findsNWidgets(2));
    });

    testWidgets('removeExercise decreases rendered Exercise count',
        (tester) async {
      final ex = _data('Deadlift');
      await tester.pumpWidget(_wrap(
        Workout(key: key, name: 'W', exercises: [_data('Squat'), ex]),
      ));
      expect(find.byType(Exercise), findsNWidgets(2));

      final state = key.currentState!;
      // ignore: invalid_use_of_protected_member
      (state as dynamic).removeExercise(ex);
      await tester.pump();

      expect(find.byType(Exercise), findsNWidgets(1));
    });

    testWidgets('removing non-existent exercise leaves count unchanged',
        (tester) async {
      await tester.pumpWidget(_wrap(
        Workout(key: key, name: 'W', exercises: [_data('Squat')]),
      ));
      final state = key.currentState!;
      // ignore: invalid_use_of_protected_member
      (state as dynamic).removeExercise(_data('Ghost Exercise'));
      await tester.pump();

      expect(find.byType(Exercise), findsNWidgets(1));
    });
  });

  // =========================================================================
  // 5. State mutations — addTag / removeTag / deduplication
  // =========================================================================
  group('Workout state: tags', () {
    late GlobalKey<State> key;

    setUp(() {
      key = GlobalKey();
    });

    testWidgets('addTag renders new Chip', (tester) async {
      await tester.pumpWidget(_wrap(Workout(key: key, name: 'W')));
      expect(find.byType(Chip), findsNothing);

      final state = key.currentState!;
      // ignore: invalid_use_of_protected_member
      (state as dynamic).addTag(_strengthTag);
      await tester.pump();

      expect(find.byType(Chip), findsOneWidget);
      expect(find.text('Strength'), findsOneWidget);
    });

    testWidgets('addTag is idempotent — duplicate tag not added twice',
        (tester) async {
      await tester.pumpWidget(_wrap(Workout(key: key, name: 'W')));

      final state = key.currentState!;
      // ignore: invalid_use_of_protected_member
      (state as dynamic).addTag(_strengthTag);
      // ignore: invalid_use_of_protected_member
      (state as dynamic).addTag(_strengthTag);
      await tester.pump();

      // LinkedHashSet prevents duplicates
      expect(find.byType(Chip), findsNWidgets(1));
    });

    testWidgets('removeTag removes its Chip', (tester) async {
      await tester.pumpWidget(_wrap(
        Workout(key: key, name: 'W', tags: [_strengthTag, _cardioTag]),
      ));
      expect(find.byType(Chip), findsNWidgets(2));

      final state = key.currentState!;
      // ignore: invalid_use_of_protected_member
      (state as dynamic).removeTag(_cardioTag);
      await tester.pump();

      expect(find.byType(Chip), findsNWidgets(1));
      expect(find.text('Cardio'), findsNothing);
    });

    testWidgets('removing absent tag leaves chips unchanged', (tester) async {
      await tester.pumpWidget(_wrap(
        Workout(key: key, name: 'W', tags: [_strengthTag]),
      ));
      final state = key.currentState!;
      // ignore: invalid_use_of_protected_member
      (state as dynamic).removeTag(_cardioTag);
      await tester.pump();

      expect(find.byType(Chip), findsNWidgets(1));
    });
  });

  // =========================================================================
  // 6. Default argument behaviour
  // =========================================================================
  group('Workout default arguments', () {
    testWidgets('exercises defaults to empty list', (tester) async {
      await tester.pumpWidget(_wrap(Workout(name: 'W')));
      expect(find.byType(Exercise), findsNothing);
    });

    testWidgets('tags defaults to empty list', (tester) async {
      await tester.pumpWidget(_wrap(Workout(name: 'W')));
      expect(find.byType(Chip), findsNothing);
    });
  });
}
