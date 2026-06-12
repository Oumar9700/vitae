import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String uid;
  final String email;
  final String nom;
  final String prenom;
  final String sexe; // 'M', 'F', 'Autre'
  final int age;
  final double poidsKg;
  final int tailleCm;
  final double poidsObjectifKg;
  final int delaiSemaines;
  final String niveauActivite;
  final List<String> conditionsSante;
  final List<String> allergies;
  final String regime;
  final List<String> cuisinesPreferees;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.sexe,
    required this.age,
    required this.poidsKg,
    required this.tailleCm,
    required this.poidsObjectifKg,
    required this.delaiSemaines,
    required this.niveauActivite,
    this.conditionsSante = const [],
    this.allergies = const [],
    this.regime = 'omnivore',
    this.cuisinesPreferees = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => '$prenom $nom';

  double get bmi => poidsKg / ((tailleCm / 100) * (tailleCm / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Insuffisance pondérale';
    if (bmi < 25) return 'Poids normal';
    if (bmi < 30) return 'Surpoids';
    return 'Obésité';
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? nom,
    String? prenom,
    String? sexe,
    int? age,
    double? poidsKg,
    int? tailleCm,
    double? poidsObjectifKg,
    int? delaiSemaines,
    String? niveauActivite,
    List<String>? conditionsSante,
    List<String>? allergies,
    String? regime,
    List<String>? cuisinesPreferees,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      sexe: sexe ?? this.sexe,
      age: age ?? this.age,
      poidsKg: poidsKg ?? this.poidsKg,
      tailleCm: tailleCm ?? this.tailleCm,
      poidsObjectifKg: poidsObjectifKg ?? this.poidsObjectifKg,
      delaiSemaines: delaiSemaines ?? this.delaiSemaines,
      niveauActivite: niveauActivite ?? this.niveauActivite,
      conditionsSante: conditionsSante ?? this.conditionsSante,
      allergies: allergies ?? this.allergies,
      regime: regime ?? this.regime,
      cuisinesPreferees: cuisinesPreferees ?? this.cuisinesPreferees,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uid, email, nom, prenom, sexe, age, poidsKg, tailleCm,
        poidsObjectifKg, delaiSemaines, niveauActivite,
        regime, updatedAt,
      ];
}
