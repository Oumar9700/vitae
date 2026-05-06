part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final UserProfile profile;
  const AuthSignupRequested({required this.email, required this.password, required this.profile});
  @override
  List<Object?> get props => [email, profile];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  const AuthPasswordResetRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class AuthProfileUpdateRequested extends AuthEvent {
  final UserProfile profile;
  const AuthProfileUpdateRequested(this.profile);
  @override
  List<Object?> get props => [profile];
}

class AuthUserChanged extends AuthEvent {
  final UserProfile? user;
  const AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}
