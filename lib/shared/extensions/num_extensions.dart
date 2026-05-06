extension NumExtensions on double {
  String get formatted {
    if (this == truncateToDouble()) return toInt().toString();
    return toStringAsFixed(1);
  }

  String get kcal => '${toInt()} kcal';
  String get grams => '${formatted}g';
  String get mg => '${toInt()} mg';
}

extension IntExtensions on int {
  String get kcal => '$this kcal';
}
