import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserProfileModel> login({required String email, required String password});
  Future<UserProfileModel> signup({required String email, required String password, required UserProfile profile});
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<UserProfileModel?> getCurrentUser();
  Future<UserProfileModel> updateProfile(UserProfile profile);
  Stream<UserProfileModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  @override
  Future<UserProfileModel> login({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fetchProfile(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  @override
  Future<UserProfileModel> signup({
    required String email,
    required String password,
    required UserProfile profile,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final model = UserProfileModel.fromEntity(
        profile.copyWith(uid: uid, email: email),
      );
      await _firestore.collection('users').doc(uid).set(model.toFirestore());
      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  @override
  Future<UserProfileModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.uid);
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfile profile) async {
    final model = UserProfileModel.fromEntity(
      profile.copyWith(updatedAt: DateTime.now()),
    );
    await _firestore.collection('users').doc(profile.uid).update(model.toFirestore());
    return model;
  }

  @override
  Stream<UserProfileModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        return await _fetchProfile(user.uid);
      } catch (_) {
        return null;
      }
    });
  }

  Future<UserProfileModel> _fetchProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw const NotFoundException('Profil introuvable.');
    return UserProfileModel.fromFirestore(doc.data()!, uid);
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found': return 'Aucun compte avec cet email.';
      case 'wrong-password': return 'Mot de passe incorrect.';
      case 'email-already-in-use': return 'Cet email est déjà utilisé.';
      case 'invalid-email': return 'Email invalide.';
      case 'weak-password': return 'Mot de passe trop faible.';
      case 'too-many-requests': return 'Trop de tentatives. Réessaie plus tard.';
      case 'network-request-failed': return 'Pas de connexion internet.';
      default: return 'Erreur d\'authentification.';
    }
  }
}
