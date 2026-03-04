import 'dart:ui';

import 'package:auksine_bycke/utils/workout_tags/workout_tag.dart';

class LowerBodyTag implements WorkoutTag {
  @override
  String getTag() {
    return "Lower Body";
  }

  @override
  Color getColor() {
    return Color.fromRGBO(191, 98, 24, 1.0);
  }
}