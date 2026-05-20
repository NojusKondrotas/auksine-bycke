import 'dart:collection';

import 'package:auksine_bycke/utils/exercise_catalog.dart';
import 'package:auksine_bycke/utils/exercise_data.dart';
import 'package:auksine_bycke/utils/exercise_info.dart';
import 'package:auksine_bycke/utils/workout_tags/workout_tag.dart';
import 'package:auksine_bycke/widgets/workout_plan/exercise.dart';
import 'package:flutter/material.dart';

class Workout extends StatefulWidget {
  final String name;
  final List<ExerciseData> exercises;

  /// IDs referencing entries in [predefinedExercises].
  final List<String> exerciseIds;

  final List<WorkoutTag> tags;

  Workout({
    super.key,
    required this.name,
    List<ExerciseData>? exercises,
    List<String>? exerciseIds,
    List<WorkoutTag>? tags,
  })  : exercises = exercises ?? [],
        exerciseIds = exerciseIds ?? [],
        tags = tags ?? [];

  @override
  State<StatefulWidget> createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> {
  late final String _name;
  late final List<ExerciseData> _exercises;
  late final List<String> _exerciseIds;
  late final LinkedHashSet<WorkoutTag> _tags;

  // ---------------------------------------------------------------------------
  // Resolved ExerciseInfo list (derived from _exerciseIds at init time).
  // ---------------------------------------------------------------------------
  late final List<ExerciseInfo> _resolvedInfos;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _exercises = List.of(widget.exercises);
    _exerciseIds = List.of(widget.exerciseIds);
    _tags = LinkedHashSet.of(widget.tags);

    _resolvedInfos = _resolveExerciseInfos(_exerciseIds);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Looks up each ID in [predefinedExercises] and returns matched items.
  List<ExerciseInfo> _resolveExerciseInfos(List<String> ids) {
    final lookup = {for (final e in predefinedExercises) e.id: e};
    return ids
        .map((id) => lookup[id])
        .whereType<ExerciseInfo>() // drop nulls for unknown IDs
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Mutation helpers
  // ---------------------------------------------------------------------------

  void addExercise(ExerciseData exercise) {
    setState(() {
      _exercises.add(exercise);
    });
  }

  void removeExercise(ExerciseData exercise) {
    setState(() {
      _exercises.remove(exercise);
    });
  }

  void addExerciseById(String id) {
    final lookup = {for (final e in predefinedExercises) e.id: e};
    final info = lookup[id];
    if (info == null) return;
    setState(() {
      _exerciseIds.add(id);
      _resolvedInfos.add(info);
    });
  }

  void removeExerciseById(String id) {
    final idx = _exerciseIds.indexOf(id);
    if (idx == -1) return;
    setState(() {
      _exerciseIds.removeAt(idx);
      _resolvedInfos.removeAt(idx);
    });
  }

  void addTag(WorkoutTag tag) {
    setState(() {
      _tags.add(tag);
    });
  }

  void removeTag(WorkoutTag tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title ──────────────────────────────────────────────────────────────
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // ── Tags ───────────────────────────────────────────────────────────────
        if (_tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _tags
                    .map(
                      (tag) => Chip(
                    label: Text(tag.getTag()),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      color: tag.getColor(),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                    .toList(),
              ),
            ),
          ),

        const SizedBox(height: 6),

        // ── Divider ────────────────────────────────────────────────────────────
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FractionallySizedBox(
              widthFactor: 0.9,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color:
                  Theme.of(context).colorScheme.onSurface.withAlpha(51),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // ── Legacy ExerciseData list ───────────────────────────────────────────
        if (_exercises.isNotEmpty)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: _exercises.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < _exercises.length - 1 ? 10 : 0,
                ),
                child: Exercise(exerciseData: entry.value),
              );
            }).toList(),
          ),

        // ── ExerciseInfo list (resolved from IDs) ──────────────────────────────
        if (_resolvedInfos.isNotEmpty)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: _resolvedInfos.asMap().entries.expand((entry) {
              return [
                _ExerciseInfoTile(info: entry.value),
                if (entry.key < _resolvedInfos.length - 1)
                  const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
              ];
            }).toList(),
          ),
      ],
    );
  }
}

// =============================================================================
// _ExerciseInfoTile — compact card used inside the Workout widget
// =============================================================================

class _ExerciseInfoTile extends StatelessWidget {
  final ExerciseInfo info;

  const _ExerciseInfoTile({required this.info});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _showDetail(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    info.muscles.join(' · '),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ExerciseDetailSheet(info: info),
    );
  }
}

// =============================================================================
// _ExerciseDetailSheet — bottom sheet with full exercise details
// =============================================================================

class _ExerciseDetailSheet extends StatelessWidget {
  final ExerciseInfo info;

  const _ExerciseDetailSheet({required this.info});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag handle ─────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Exercise name ────────────────────────────────────────────────
              Text(
                info.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // ── Muscle / body-part chips ─────────────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  ...info.muscles.map(
                        (m) => Chip(
                      label: Text(m),
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                  ),
                  ...info.bodyParts.map(
                        (b) => Chip(
                      label: Text(b),
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: colorScheme.tertiaryContainer,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Instructions ─────────────────────────────────────────────────
              Text(
                'Instructions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              ...info.instructions.asMap().entries.map(
                    (e) => _InstructionStep(
                  number: e.key + 1,
                  text: e.value,
                ),
              ),

              // ── Demo media ───────────────────────────────────────────────────
              if (info.mediaPaths.isNotEmpty) ...[
                const SizedBox(height: 20),
                _SectionHeader(title: 'Demo', icon: Icons.play_circle_outline),
                const SizedBox(height: 10),
                ...info.mediaPaths.map(
                      (path) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          color: colorScheme.surfaceVariant,
                          child: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// Small reusable widgets
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String text;

  const _InstructionStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outline,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}