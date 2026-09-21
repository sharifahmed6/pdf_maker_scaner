import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}
class AuthSignInWithEmail extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInWithEmail(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}
class AuthSignUpWithEmail extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const AuthSignUpWithEmail(this.name, this.email, this.password);
  @override
  List<Object?> get props => [name, email, password];
}
class AuthSignOut extends AuthEvent {}
