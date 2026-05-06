import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/meal_entry_model.dart';

abstract class MealRemoteDataSource {
  Future<MealEntryModel> addMeal(MealEntryModel entry);
  Future<MealEntryModel> updateMeal(MealEntryModel entry);
  Future<void> deleteMeal(String entryId, String userId, DateTime date);
  Future<List<MealEntryModel>> getDailyMeals(String userId, DateTime date);
  Stream<List<MealEntryModel>> watchDailyMeals(String userId, DateTime date);
}

class MealRemoteDataSourceImpl implements MealRemoteDataSource {
  final FirebaseFirestore _firestore;

  MealRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference _mealsRef(String userId, DateTime date) {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _firestore.collection('users').doc(userId).collection('meals').doc(dateKey).collection('entries');
  }

  @override
  Future<MealEntryModel> addMeal(MealEntryModel entry) async {
    try {
      final ref = _mealsRef(entry.userId, entry.date).doc(entry.id);
      await ref.set(entry.toFirestore());
      return entry;
    } catch (e) {
      throw ServerException('Erreur lors de l\'ajout du repas.');
    }
  }

  @override
  Future<MealEntryModel> updateMeal(MealEntryModel entry) async {
    try {
      final ref = _mealsRef(entry.userId, entry.date).doc(entry.id);
      await ref.update(entry.toFirestore());
      return entry;
    } catch (e) {
      throw ServerException('Erreur lors de la modification.');
    }
  }

  @override
  Future<void> deleteMeal(String entryId, String userId, DateTime date) async {
    try {
      await _mealsRef(userId, date).doc(entryId).delete();
    } catch (e) {
      throw ServerException('Erreur lors de la suppression.');
    }
  }

  @override
  Future<List<MealEntryModel>> getDailyMeals(String userId, DateTime date) async {
    try {
      final snapshot = await _mealsRef(userId, date).get();
      return snapshot.docs
          .map((doc) => MealEntryModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Erreur lors du chargement des repas.');
    }
  }

  @override
  Stream<List<MealEntryModel>> watchDailyMeals(String userId, DateTime date) {
    return _mealsRef(userId, date).snapshots().map((snapshot) => snapshot.docs
        .map((doc) => MealEntryModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }
}
