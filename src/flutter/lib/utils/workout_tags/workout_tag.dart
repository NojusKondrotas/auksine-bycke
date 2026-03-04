import 'dart:ui';

abstract class WorkoutTag {
  String getTag();
  Color getColor();

  @override
  bool operator ==(Object other) {
    if(identical(this, other)) return true;

    return other is WorkoutTag
        && other.getTag() == getTag();
  }

  @override
  int get hashCode => getTag().hashCode;
}