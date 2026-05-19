class ExerciseInfo {
  final String id;
  final String name;
  final List<String> muscles;
  final List<String> bodyParts;
  final List<String> instructions;
  final List<String> mediaPaths;

  const ExerciseInfo({
    required this.id,
    required this.name,
    required this.muscles,
    required this.bodyParts,
    required this.instructions,
    this.mediaPaths = const [],
  });
}