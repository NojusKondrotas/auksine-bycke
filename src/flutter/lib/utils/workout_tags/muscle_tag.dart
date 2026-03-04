import 'dart:ui';

import 'package:auksine_bycke/utils/workout_tags/workout_tag.dart';

class MuscleTag implements WorkoutTag {
  @override
  String getTag() {
    return "Muscle";
  }

  @override
  Color getColor() {
    return Color.fromRGBO(126, 90, 230, 1.0);
  }
}