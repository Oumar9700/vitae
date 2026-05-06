import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserProfile>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserProfile>> signup({
    required String email,
    required String password,
    required UserProfile profile,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> resetPassword(String email);

  Future<Either<Failure, UserProfile?>> getCurrentUser();

  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile);

  Stream<UserProfile?> get authStateChanges;
}
