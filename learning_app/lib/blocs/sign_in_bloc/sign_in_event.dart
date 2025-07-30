part of 'sign_in_bloc.dart';

abstract class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object> get props => [];
}

class SignInRequired extends SignInEvent {
  final String email;
  final String password;

  const SignInRequired(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class GoogleSignInRequired extends SignInEvent {
  const GoogleSignInRequired();

  @override
  List<Object> get props => [];
}

class SignOutRequired extends SignInEvent {
  const SignOutRequired();

  @override
  List<Object> get props => [];
}

class ResetPasswordRequired extends SignInEvent {
  final String email;

  const ResetPasswordRequired(this.email);

  @override
  List<Object> get props => [email];
}
