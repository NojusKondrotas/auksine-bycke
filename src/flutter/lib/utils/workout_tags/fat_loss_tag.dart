import 'dart:ui';

import 'package:auksine_bycke/utils/workout_tags/workout_tag.dart';

class FatLossTag implements WorkoutTag {
  @override
  String getTag() {
    return "Fat Loss";
  }

  @override
  Color getColor() {
    return Color.fromRGBO(26, 175, 161, 1.0);
  }
}