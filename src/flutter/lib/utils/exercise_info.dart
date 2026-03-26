class ExerciseInfo {
  final String id;
  final String name;
  final String shortDescription;
  final String fullDescription;
  final List<String> mediaIds;

  const ExerciseInfo({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.fullDescription,
    required this.mediaIds,
  });
}