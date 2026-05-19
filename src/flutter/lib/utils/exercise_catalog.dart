import 'package:auksine_bycke/utils/exercise_info.dart';

const List<ExerciseInfo> predefinedExercises = [

  // ================= CHEST =================
  
  ExerciseInfo(
    id: 'bench_press',
    name: 'Bench Press',
    muscles: ['pectorals', 'triceps', 'shoulders'],
    bodyParts: ['chest'],
    instructions: [
      'Lie on the bench.',
      'Lower the bar to your chest.',
      'Press upward.',
    ],
    
  ),

  ExerciseInfo(
    id: 'incline_bench_press',
    name: 'Incline Bench Press',
    muscles: ['upper chest', 'triceps', 'shoulders'],
    bodyParts: ['chest'],
    instructions: [
      'Set incline bench.',
      'Lower the bar slowly.',
      'Push upward.',
    ],
    
  ),

  ExerciseInfo(
    id: 'decline_bench_press',
    name: 'Decline Bench Press',
    muscles: ['lower chest', 'triceps'],
    bodyParts: ['chest'],
    instructions: [
      'Lie on decline bench.',
      'Lower bar carefully.',
      'Press upward.',
    ],
    
  ),

  ExerciseInfo(
    id: 'push_up',
    name: 'Push Up',
    muscles: ['pectorals', 'triceps', 'core'],
    bodyParts: ['chest'],
    instructions: [
      'Place hands shoulder-width apart.',
      'Lower body.',
      'Push upward.',
    ],
  
  ),

  ExerciseInfo(
    id: 'cable_crossover',
    name: 'Cable Crossover',
    muscles: ['pectorals'],
    bodyParts: ['chest'],
    instructions: [
      'Grab both cable handles.',
      'Bring hands together.',
      'Slowly return.',
    ],
   
  ),

  ExerciseInfo(
    id: 'dumbbell_fly',
    name: 'Dumbbell Fly',
    muscles: ['pectorals'],
    bodyParts: ['chest'],
    instructions: [
      'Lie on bench.',
      'Open arms wide.',
      'Bring dumbbells together.',
    ],
   
  ),

  // ================= BACK =================

  ExerciseInfo(
    id: 'deadlift',
    name: 'Deadlift',
    muscles: ['back', 'glutes', 'hamstrings'],
    bodyParts: ['back'],
    instructions: [
      'Grip the bar.',
      'Keep back straight.',
      'Lift upward.',
    ],
   
  ),

  ExerciseInfo(
    id: 'pull_up',
    name: 'Pull Up',
    muscles: ['lats', 'biceps'],
    bodyParts: ['back'],
    instructions: [
      'Hang from bar.',
      'Pull body upward.',
      'Lower slowly.',
    ],
   
  ),

  ExerciseInfo(
    id: 'lat_pulldown',
    name: 'Lat Pulldown',
    muscles: ['lats', 'biceps'],
    bodyParts: ['back'],
    instructions: [
      'Grab the bar.',
      'Pull to chest.',
      'Release slowly.',
    ],
   
  ),

  ExerciseInfo(
    id: 'barbell_row',
    name: 'Barbell Row',
    muscles: ['lats', 'traps'],
    bodyParts: ['back'],
    instructions: [
      'Bend slightly forward.',
      'Pull bar to stomach.',
      'Lower slowly.',
    ],
  ),

  ExerciseInfo(
    id: 'seated_cable_row',
    name: 'Seated Cable Row',
    muscles: ['middle back', 'biceps'],
    bodyParts: ['back'],
    instructions: [
      'Sit upright.',
      'Pull handle toward body.',
      'Return slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'tbar_row',
    name: 'T-Bar Row',
    muscles: ['lats', 'traps'],
    bodyParts: ['back'],
    instructions: [
      'Grip T-bar.',
      'Pull upward.',
      'Lower slowly.',
    ],

  ),

  // ================= LEGS =================

  ExerciseInfo(
    id: 'squat',
    name: 'Squat',
    muscles: ['quadriceps', 'glutes'],
    bodyParts: ['legs'],
    instructions: [
      'Stand shoulder-width apart.',
      'Lower hips.',
      'Stand back up.',
    ],

  ),

  ExerciseInfo(
    id: 'front_squat',
    name: 'Front Squat',
    muscles: ['quadriceps', 'core'],
    bodyParts: ['legs'],
    instructions: [
      'Place bar on shoulders.',
      'Squat down.',
      'Stand upward.',
    ],

  ),

  ExerciseInfo(
    id: 'leg_press',
    name: 'Leg Press',
    muscles: ['quadriceps', 'glutes'],
    bodyParts: ['legs'],
    instructions: [
      'Place feet on platform.',
      'Push upward.',
      'Lower carefully.',
    ],

  ),

  ExerciseInfo(
    id: 'lunges',
    name: 'Lunges',
    muscles: ['quadriceps', 'glutes'],
    bodyParts: ['legs'],
    instructions: [
      'Step forward.',
      'Lower body.',
      'Push back.',
    ],

  ),

  ExerciseInfo(
    id: 'romanian_deadlift',
    name: 'Romanian Deadlift',
    muscles: ['hamstrings', 'glutes'],
    bodyParts: ['legs'],
    instructions: [
      'Lower bar slowly.',
      'Keep legs slightly bent.',
      'Return upright.',
    ],

  ),

  ExerciseInfo(
    id: 'leg_extension',
    name: 'Leg Extension',
    muscles: ['quadriceps'],
    bodyParts: ['legs'],
    instructions: [
      'Sit on machine.',
      'Extend legs upward.',
      'Lower slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'leg_curl',
    name: 'Leg Curl',
    muscles: ['hamstrings'],
    bodyParts: ['legs'],
    instructions: [
      'Lie on machine.',
      'Curl legs upward.',
      'Lower slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'calf_raise',
    name: 'Calf Raise',
    muscles: ['calves'],
    bodyParts: ['legs'],
    instructions: [
      'Raise heels upward.',
      'Pause briefly.',
      'Lower slowly.',
    ],

  ),

  // ================= SHOULDERS =================

  ExerciseInfo(
    id: 'shoulder_press',
    name: 'Shoulder Press',
    muscles: ['delts', 'triceps'],
    bodyParts: ['shoulders'],
    instructions: [
      'Press weights upward.',
      'Lock arms gently.',
      'Lower slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'arnold_press',
    name: 'Arnold Press',
    muscles: ['delts', 'triceps'],
    bodyParts: ['shoulders'],
    instructions: [
      'Rotate dumbbells upward.',
      'Press overhead.',
      'Lower slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'lateral_raise',
    name: 'Lateral Raise',
    muscles: ['side delts'],
    bodyParts: ['shoulders'],
    instructions: [
      'Lift dumbbells sideways.',
      'Reach shoulder height.',
      'Lower slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'front_raise',
    name: 'Front Raise',
    muscles: ['front delts'],
    bodyParts: ['shoulders'],
    instructions: [
      'Raise weights forward.',
      'Reach shoulder level.',
      'Lower slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'rear_delt_fly',
    name: 'Rear Delt Fly',
    muscles: ['rear delts'],
    bodyParts: ['shoulders'],
    instructions: [
      'Bend forward.',
      'Raise arms outward.',
      'Lower slowly.',
    ],

  ),

  // ================= BICEPS =================

  ExerciseInfo(
    id: 'barbell_curl',
    name: 'Barbell Curl',
    muscles: ['biceps'],
    bodyParts: ['arms'],
    instructions: [
      'Grip the bar.',
      'Curl upward.',
      'Lower slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'hammer_curl',
    name: 'Hammer Curl',
    muscles: ['biceps', 'brachialis'],
    bodyParts: ['arms'],
    instructions: [
      'Hold dumbbells neutral.',
      'Curl upward.',
      'Lower slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'preacher_curl',
    name: 'Preacher Curl',
    muscles: ['biceps'],
    bodyParts: ['arms'],
    instructions: [
      'Place arms on pad.',
      'Curl upward.',
      'Lower slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'cable_curl',
    name: 'Cable Curl',
    muscles: ['biceps'],
    bodyParts: ['arms'],
    instructions: [
      'Grab cable handle.',
      'Curl upward.',
      'Lower slowly.',
    ],

  ),

  // ================= TRICEPS =================

  ExerciseInfo(
    id: 'tricep_pushdown',
    name: 'Tricep Pushdown',
    muscles: ['triceps'],
    bodyParts: ['arms'],
    instructions: [
      'Push cable downward.',
      'Extend arms fully.',
      'Return slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'skullcrusher',
    name: 'Skullcrusher',
    muscles: ['triceps'],
    bodyParts: ['arms'],
    instructions: [
      'Lower bar to forehead.',
      'Extend arms upward.',
      'Repeat slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'overhead_extension',
    name: 'Overhead Extension',
    muscles: ['triceps'],
    bodyParts: ['arms'],
    instructions: [
      'Hold weight overhead.',
      'Lower behind head.',
      'Extend upward.',
    ],

  ),

  ExerciseInfo(
    id: 'close_grip_bench',
    name: 'Close Grip Bench Press',
    muscles: ['triceps', 'chest'],
    bodyParts: ['arms'],
    instructions: [
      'Use close grip.',
      'Lower bar carefully.',
      'Press upward.',
    ],

  ),

  // ================= ABS =================

  ExerciseInfo(
    id: 'crunch',
    name: 'Crunch',
    muscles: ['abs'],
    bodyParts: ['core'],
    instructions: [
      'Lie on floor.',
      'Raise shoulders.',
      'Lower slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'plank',
    name: 'Plank',
    muscles: ['core'],
    bodyParts: ['core'],
    instructions: [
      'Hold plank position.',
      'Keep body straight.',
      'Maintain tension.',
    ],

  ),

  ExerciseInfo(
    id: 'russian_twist',
    name: 'Russian Twist',
    muscles: ['abs', 'obliques'],
    bodyParts: ['core'],
    instructions: [
      'Sit slightly leaned back.',
      'Rotate torso side to side.',
      'Repeat slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'hanging_leg_raise',
    name: 'Hanging Leg Raise',
    muscles: ['lower abs'],
    bodyParts: ['core'],
    instructions: [
      'Hang from bar.',
      'Raise legs upward.',
      'Lower slowly.',
    ],

  ),

  // ================= FOREARMS =================

  ExerciseInfo(
    id: 'wrist_curl',
    name: 'Wrist Curl',
    muscles: ['forearms'],
    bodyParts: ['arms'],
    instructions: [
      'Rest forearms on bench.',
      'Curl wrists upward.',
      'Lower slowly.',
    ],

  ),

  ExerciseInfo(
    id: 'reverse_wrist_curl',
    name: 'Reverse Wrist Curl',
    muscles: ['forearms'],
    bodyParts: ['arms'],
    instructions: [
      'Use overhand grip.',
      'Raise wrists upward.',
      'Lower slowly.',
    ],

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