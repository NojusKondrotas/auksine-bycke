import 'package:auksine_bycke/utils/exercise_catalog.dart';
import 'package:auksine_bycke/utils/exercise_info.dart';
import 'package:auksine_bycke/utils/workout_tags/workout_tag.dart';
import 'package:flutter/material.dart';

class RoutineDetailPage extends StatefulWidget {
  final String workoutName;

  final List<String> exerciseIds;

  final List<WorkoutTag> tags;

  const RoutineDetailPage({
    super.key,
    required this.workoutName,
    required this.exerciseIds,
    this.tags = const [],
  });

  @override
  State<RoutineDetailPage> createState() => _RoutineDetailPageState();
}

class _RoutineDetailPageState extends State<RoutineDetailPage> {
  late final List<ExerciseInfo> _exercises;

  @override
  void initState() {
    super.initState();
    final lookup = {for (final e in predefinedExercises) e.id: e};
    _exercises = widget.exerciseIds
        .map((id) => lookup[id])
        .whereType<ExerciseInfo>()
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── Collapsible header ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: colorScheme.surfaceTint,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Text(
                widget.workoutName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.secondaryContainer,
                    ],
                  ),
                ),
                child: const Align(
                  alignment: Alignment(0.9, -0.5),
                  child: Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),

          // ── Tags ────────────────────────────────────────────────────────────
          if (widget.tags.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.tags
                      .map(
                        (tag) => Chip(
                      label: Text(tag.getTag()),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        color: tag.getColor(),
                      ),
                      materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                      .toList(),
                ),
              ),
            ),

          // ── Exercise count summary ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.format_list_numbered,
                      size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${_exercises.length} exercise${_exercises.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Divider ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color: colorScheme.outlineVariant,
                height: 1,
              ),
            ),
          ),

          // ── Empty state ───────────────────────────────────────────────────────
          if (_exercises.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 56, color: colorScheme.outlineVariant),
                    const SizedBox(height: 12),
                    Text(
                      'No exercises in this workout yet.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),

          // ── Exercise cards ───────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            sliver: SliverList.separated(
              itemCount: _exercises.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return _WorkoutExerciseCard(
                  index: index,
                  info: exercise,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// _WorkoutExerciseCard
// =============================================================================

class _WorkoutExerciseCard extends StatelessWidget {
  final int index;
  final ExerciseInfo info;

  const _WorkoutExerciseCard({required this.index, required this.info});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Ordinal badge ──────────────────────────────────────────────
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // ── Labels ─────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.muscles.join(' · '),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: info.bodyParts
                          .map(
                            (part) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            part,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ],
                ),
              ),

              // ── Preview icon ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Detail bottom sheet
  // ---------------------------------------------------------------------------

  void _openDetail(BuildContext context) {
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
// _ExerciseDetailSheet
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag handle ────────────────────────────────────────────────
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

              // ── Title ──────────────────────────────────────────────────────
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    radius: 22,
                    child: Icon(
                      Icons.fitness_center,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      info.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Muscle / body-part chips ───────────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  ...info.muscles.map(
                        (m) => _InfoChip(
                      label: m,
                      icon: Icons.sports_gymnastics,
                      background: colorScheme.secondaryContainer,
                      foreground: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  ...info.bodyParts.map(
                        (b) => _InfoChip(
                      label: b,
                      icon: Icons.accessibility_new,
                      background: colorScheme.tertiaryContainer,
                      foreground: colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Instructions ───────────────────────────────────────────────
              _SectionHeader(title: 'Instructions', icon: Icons.list_alt),
              const SizedBox(height: 12),
              ...info.instructions.asMap().entries.map(
                    (e) => _InstructionStep(
                  number: e.key + 1,
                  text: e.value,
                ),
              ),

              // ── Demo media ─────────────────────────────────────────────────
              if (info.mediaPaths.isNotEmpty) ...[
                const SizedBox(height: 24),
                _SectionHeader(
                    title: 'Demo', icon: Icons.play_circle_outline),
                const SizedBox(height: 12),
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
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
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
// Small reusable sub-widgets
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color,
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
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primaryContainer,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text, style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _InfoChip({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: foreground),
          ),
        ],
      ),
    );
  }
}