import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.email,
    required super.nom,
    required super.prenom,
    required super.sexe,
    required super.age,
    required super.poidsKg,
    required super.tailleCm,
    required super.poidsObjectifKg,
    required super.delaiSemaines,
    required super.niveauActivite,
    super.conditionsSante,
    super.allergies,
    super.regime,
    super.cuisinesPreferees,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromFirestore(Map<String, dynamic> map, String uid) {
    return UserProfileModel(
      uid: uid,
      email: map['email'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      sexe: map['sexe'] ?? 'M',
      age: (map['age'] ?? 25) as int,
      poidsKg: (map['poids_kg'] ?? 70.0).toDouble(),
      tailleCm: (map['taille_cm'] ?? 170) as int,
      poidsObjectifKg: (map['poids_objectif_kg'] ?? 70.0).toDouble(),
      delaiSemaines: (map['delai_semaines'] ?? 12) as int,
      niveauActivite: map['niveau_activite'] ?? 'modere',
      conditionsSante: List<String>.from(map['conditions_sante'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
      regime: map['regime'] ?? 'omnivore',
      cuisinesPreferees: List<String>.from(map['cuisines_preferees'] ?? []),
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      uid: profile.uid,
      email: profile.email,
      nom: profile.nom,
      prenom: profile.prenom,
      sexe: profile.sexe,
      age: profile.age,
      poidsKg: profile.poidsKg,
      tailleCm: profile.tailleCm,
      poidsObjectifKg: profile.poidsObjectifKg,
      delaiSemaines: profile.delaiSemaines,
      niveauActivite: profile.niveauActivite,
      conditionsSante: profile.conditionsSante,
      allergies: profile.allergies,
      regime: profile.regime,
      cuisinesPreferees: profile.cuisinesPreferees,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'sexe': sexe,
      'age': age,
      'poids_kg': poidsKg,
      'taille_cm': tailleCm,
      'poids_objectif_kg': poidsObjectifKg,
      'delai_semaines': delaiSemaines,
      'niveau_activite': niveauActivite,
      'conditions_sante': conditionsSante,
      'allergies': allergies,
      'regime': regime,
      'cuisines_preferees': cuisinesPreferees,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}
