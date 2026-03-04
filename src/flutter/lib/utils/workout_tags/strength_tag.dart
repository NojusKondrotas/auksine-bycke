import 'dart:ui';

import 'package:auksine_bycke/utils/workout_tags/workout_tag.dart';

class StrengthTag implements WorkoutTag {
  @override
  String getTag() {
    return "Strength";
  }

  @override
  Color getColor() {
    return Color.fromRGBO(26, 168, 49, 1.0);
  }
}