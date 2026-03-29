import 'package:auksine_bycke/utils/exercise_info.dart';

const List<ExerciseInfo> predefinedExercises = [
  ExerciseInfo(
    id: '1',
    name: 'Bench Press',
    shortDescription: 'Horizontal push.',
    fullDescription:
        'A compound pressing movement performed supine on a bench. Primarily targets the pectoralis major, with secondary involvement of the anterior deltoid and triceps.',
    mediaIds: [],
  ),
  ExerciseInfo(
    id: '2',
    name: 'Squat',
    shortDescription: 'Bilateral leg drive.',
    fullDescription:
        'A foundational lower-body movement loaded through the axial skeleton. Recruits the quadriceps, glutes, and erector spinae through a full knee and hip flexion cycle.',
    mediaIds: [],
  ),
  ExerciseInfo(
    id: '3',
    name: 'Deadlift',
    shortDescription: 'Hip hinge pull.',
    fullDescription:
        'A posterior chain dominant lift initiating from a dead stop on the floor. Engages the hamstrings, glutes, spinal erectors, and upper back under maximal tension.',
    mediaIds: [],
  ),
  ExerciseInfo(
    id: '4',
    name: 'Overhead Press',
    shortDescription: 'Vertical push.',
    fullDescription:
        'A standing barbell press performed in the vertical plane. Primarily loads the deltoids and triceps, demanding significant core and upper back stabilisation.',
    mediaIds: [],
  ),
  ExerciseInfo(
    id: '5',
    name: 'Pull-Up',
    shortDescription: 'Vertical pull.',
    fullDescription:
        'A bodyweight vertical pulling movement. Targets the latissimus dorsi and biceps brachii, with the grip width dictating emphasis across the back.',
    mediaIds: [],
  ),
  ExerciseInfo(
    id: '6',
    name: 'Barbell Row',
    shortDescription: 'Horizontal pull.',
    fullDescription:
        'A bent-over rowing movement against horizontal resistance. Develops the mid and upper back, with significant isometric demand on the lower back.',
    mediaIds: [],
  ),
  ExerciseInfo(
    id: '7',
    name: 'Dumbbell Curl',
    shortDescription: 'Elbow flexion.',
    fullDescription:
        'An isolation movement targeting the biceps brachii through a full range of elbow flexion. Dumbbells allow independent arm tracking and supination throughout the curl.',
    mediaIds: [],
  ),
  ExerciseInfo(
    id: '8',
    name: 'Tricep Pushdown',
    shortDescription: 'Elbow extension.',
    fullDescription:
        'A cable-based isolation exercise for the triceps brachii. The fixed upper arm position eliminates shoulder involvement, placing the entire load through elbow extension.',
    mediaIds: [],
  ),
];

ExerciseInfo? getExerciseById(String id) {
  for (final exercise in predefinedExercises) {
    if (exercise.id == id) {
      return exercise;
    }
  }
  return null;
}

ExerciseInfo? getExerciseByName(String name) {
  for (final exercise in predefinedExercises) {
    if (exercise.name == name) {
      return exercise;
    }
  }
  return null;
}
