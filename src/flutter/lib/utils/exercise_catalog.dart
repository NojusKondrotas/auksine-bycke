import 'package:auksine_bycke/utils/exercise_info.dart';

const List<ExerciseInfo> predefinedExercises = [
  ExerciseInfo(
    id: '2ORFMoR',
    name: 'Half calf raise',
    muscles: ['calves', 'hamstrings', 'glutes'],
    bodyParts: ['lower legs'],
    instructions: [
      'Adjust the sled machine to a comfortable weight.',
      'Stand on the sled machine with your toes on the platform and your heels hanging off.',
      'Hold onto the handles for stability.',
      'Raise your heels as high as possible by pushing through the balls of your feet.',
      'Pause for a moment at the top, then slowly lower your heels back down to the starting position.',
      'Repeat for the desired number of repetitions.'
    ],
    mediaPaths: ['assets/exercises/720x720/2ORFMoR.gif'],
  ),
  ExerciseInfo(
    id: '2Qh2J1e',
    name: 'Sled 45° leg press',
    muscles: ['glutes', 'quadriceps', 'hamstrings', 'calves'],
    bodyParts: ['upper legs'],
    instructions: [
      'Adjust the seat of the sled machine so that your knees are at a 90-degree angle when your feet are on the footplate.',
      'Sit on the sled machine with your back flat against the backrest and your feet shoulder-width apart on the footplate.',
      'Grip the handles on the sides of the seat for stability.',
      'Push against the footplate to extend your legs, straightening them completely.',
      'Pause for a moment at the top, then slowly bend your knees to lower the footplate back to the starting position.',
      'Repeat for the desired number of repetitions.'
    ],
    mediaPaths: ['assets/exercises/720x720/2Qh2J1e.gif'],
  ),
  ExerciseInfo(
    id: '3eGE2JC',
    name: 'Dumbbell front raise',
    muscles: ['delts', 'biceps', 'trapezius'],
    bodyParts: ['shoulders'],
    instructions: [
      'Stand with your feet shoulder-width apart, holding a dumbbell in each hand with your palms facing your thighs.',
      'Keeping your arms straight, exhale and lift the dumbbells in front of you until they are at shoulder level.',
      'Pause for a moment at the top, then inhale and slowly lower the dumbbells back down to the starting position.',
      'Repeat for the desired number of repetitions.'
    ],
    mediaPaths: ['assets/exercises/720x720/3eGE2JC.gif'],
  ),
  ExerciseInfo(
    id: '3tAXPQ6',
    name: 'Dumbbell over bench reverse wrist curl',
    muscles: ['forearms', 'biceps', 'brachialis'],
    bodyParts: ['lower arms'],
    instructions: [
      'Sit on a bench with your feet flat on the ground and hold a dumbbell in each hand, palms facing down.',
      'Rest your forearms on the bench, allowing your wrists to hang off the edge.',
      'Slowly curl your wrists upward, bringing the dumbbells towards your body.',
      'Pause for a moment at the top, then slowly lower the dumbbells back down to the starting position.',
      'Repeat for the desired number of repetitions.'
    ],
    mediaPaths: ['assets/exercises/720x720/3tAXPQ6.gif'],
  ),
  ExerciseInfo(
    id: '3TZduzM',
    name: 'Barbell incline bench press',
    muscles: ['pectorals', 'shoulders', 'triceps'],
    bodyParts: ['chest'],
    instructions: [
      'Set up an incline bench at a 45-degree angle.',
      'Lie down on the bench with your feet flat on the ground.',
      'Grasp the barbell with an overhand grip, slightly wider than shoulder-width apart.',
      'Unrack the barbell and lower it slowly towards your chest, keeping your elbows at a 45-degree angle.',
      'Pause for a moment at the bottom, then push the barbell back up to the starting position.',
      'Repeat for the desired number of repetitions.'
    ],
    mediaPaths: ['assets/exercises/720x720/3TZduzM.gif'],
  ),
  ExerciseInfo(
    id: '3XFdb1Z',
    name: 'Cable squatting curl',
    muscles: ['biceps', 'forearms'],
    bodyParts: ['upper arms'],
    instructions: [
      'Attach a cable handle to the lowest setting on a cable machine.',
      'Stand facing the machine with your feet shoulder-width apart.',
      'Hold the cable handle with an underhand grip, palms facing up, and arms fully extended.',
      'Lower your body into a squat position, keeping your back straight and knees behind your toes.',
      'As you squat down, curl the cable handle towards your shoulders, keeping your elbows close to your sides.',
      'Pause for a moment at the top of the curl, squeezing your biceps.',
      'Slowly lower the cable handle back to the starting position, fully extending your arms.',
      'Repeat for the desired number of repetitions.'
    ],
    mediaPaths: ['assets/exercises/720x720/3XFdb1Z.gif'],
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
