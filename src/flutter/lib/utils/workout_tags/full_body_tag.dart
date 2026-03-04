import 'dart:ui';

import 'package:auksine_bycke/utils/workout_tags/workout_tag.dart';

class FullBodyTag implements WorkoutTag {
  @override
  String getTag() {
    return "Full Body";
  }

  @override
  Color getColor() {
    return Color.fromRGBO(211, 112, 31, 1.0);
  }
}