part of 'meal_bloc.dart';

abstract class MealEvent extends Equatable {
  const MealEvent();
  @override
  List<Object?> get props => [];
}

class MealLoadRequested extends MealEvent {
  final String userId;
  final DateTime date;
  final UserProfile profile;
  const MealLoadRequested({required this.userId, required this.date, required this.profile});
  @override
  List<Object?> get props => [userId, date];
}

class MealEntriesUpdated extends MealEvent {
  final List<MealEntry> entries;
  final UserProfile profile;
  final DateTime date;
  const MealEntriesUpdated({required this.entries, required this.profile, required this.date});
  @override
  List<Object?> get props => [entries, date];
}

class MealAddRequested extends MealEvent {
  final MealEntry entry;
  final Food food;
  const MealAddRequested({required this.entry, required this.food});
  @override
  List<Object?> get props => [entry];
}

class MealUpdateRequested extends MealEvent {
  final MealEntry entry;
  const MealUpdateRequested(this.entry);
  @override
  List<Object?> get props => [entry];
}

class MealDeleteRequested extends MealEvent {
  final String entryId;
  final String userId;
  final DateTime date;
  const MealDeleteRequested({required this.entryId, required this.userId, required this.date});
  @override
  List<Object?> get props => [entryId];
}

class MealFoodSearched extends MealEvent {
  final String query;
  const MealFoodSearched(this.query);
  @override
  List<Object?> get props => [query];
}

class MealDateChanged extends MealEvent {
  final String userId;
  final DateTime date;
  final UserProfile profile;
  const MealDateChanged({required this.userId, required this.date, required this.profile});
  @override
  List<Object?> get props => [date];
}
