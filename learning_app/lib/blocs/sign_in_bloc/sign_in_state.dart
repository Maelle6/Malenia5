part of 'sign_in_bloc.dart';

@immutable
abstract class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object> get props => [];
}

class SignInInitial extends SignInState {
  @override
  List<Object> get props => [];
}

class SignInSuccess extends SignInState {
  final String message;

  const SignInSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class SignInFailure extends SignInState {
  final String message;

  const SignInFailure(this.message);

  @override
  List<Object> get props => [message];
}

class SignInProcess extends SignInState {
  @override
  List<Object> get props => [];
}

class ResetPasswordInProcess extends SignInState {
  @override
  List<Object> get props => [];
}
class ResetPasswordSuccess extends SignInState {
  final String message;

  const ResetPasswordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ResetPasswordFailure extends SignInState {
  final String message;

  const ResetPasswordFailure(this.message);

  @override
  List<Object> get props => [message];
}
