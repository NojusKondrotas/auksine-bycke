import 'dart:ui';

import 'package:auksine_bycke/utils/workout_tags/workout_tag.dart';

class EnduranceTag implements WorkoutTag {
  @override
  String getTag() {
    return "Endurance";
  }
  
  @override
  Color getColor() {
    return Color.fromRGBO(211, 31, 31, 1.0);
  }
}