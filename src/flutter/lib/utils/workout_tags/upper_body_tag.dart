import 'dart:ui';

import 'package:auksine_bycke/utils/workout_tags/workout_tag.dart';

class UpperBodyTag implements WorkoutTag {
  @override
  String getTag() {
    return "Upper Body";
  }

  @override
  Color getColor() {
    return Color.fromRGBO(234, 137, 68, 1.0);
  }
}