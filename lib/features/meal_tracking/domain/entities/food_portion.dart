import 'package:equatable/equatable.dart';

class FoodPortion extends Equatable {
  final String label;
  final double grams;
  final String description;

  const FoodPortion({
    required this.label,
    required this.grams,
    this.description = '',
  });

  @override
  List<Object?> get props => [label, grams];
}

class PortionSizes {
  final double small;
  final double medium;
  final double large;

  const PortionSizes({
    required this.small,
    required this.medium,
    required this.large,
  });
}
