import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/presentation/bloc/auth_bloc.dart';
import '../features/meal_tracking/data/datasources/ciqual_local_data_source.dart';
import '../features/meal_tracking/data/datasources/meal_local_data_source.dart';
import '../features/meal_tracking/data/datasources/meal_remote_data_source.dart';
import '../features/meal_tracking/data/datasources/openfoodfacts_data_source.dart';
import '../features/meal_tracking/data/repositories/meal_repository_impl.dart';
import '../features/meal_tracking/domain/repositories/meal_repository.dart';
import '../features/meal_tracking/presentation/bloc/meal_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(auth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl()),
  );
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  sl.registerLazySingleton<MealRemoteDataSource>(
    () => MealRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<CiqualLocalDataSource>(
    () => CiqualLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<OpenFoodFactsDataSource>(
    () => OpenFoodFactsDataSourceImpl(),
  );
  sl.registerLazySingleton<MealLocalDataSource>(
    () => MealLocalDataSourceImpl(prefs: sl()),
  );
  sl.registerLazySingleton<MealRepository>(
    () => MealRepositoryImpl(
      remote: sl(),
      ciqual: sl(),
      openFoodFacts: sl(),
      local: sl(),
    ),
  );
  sl.registerFactory(() => MealBloc(mealRepository: sl()));
}
