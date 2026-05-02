import 'package:flutter/cupertino.dart';

enum UnitSystem {
  metric,
  imperial
}

class UnitSystemNotifier extends ChangeNotifier {
  UnitSystem _units = UnitSystem.metric;
  UnitSystem get units => _units;

  bool get isMetric => _units == UnitSystem.metric;

  void toggle() {
    _units = units == UnitSystem.metric
        ? UnitSystem.imperial
        : UnitSystem.metric;
    notifyListeners();
  }

  double displayWeight(double kg) {
    return isMetric ? kg : kg * 2.20462;
  }

  String weightLabel() => isMetric ? 'kg' : 'lbs';
  String heightLabel() => isMetric ? 'cm' : 'in';
}

class UnitSystemScope extends InheritedNotifier<UnitSystemNotifier> {
  const UnitSystemScope({
    super.key,
    required UnitSystemNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static UnitSystemNotifier of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<UnitSystemScope>()!
        .notifier!;
  }
}