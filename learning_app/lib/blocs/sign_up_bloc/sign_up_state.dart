part of 'sign_up_bloc.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object> get props => [];
}

class SignUpInitial extends SignUpState {
  @override
  List<Object> get props => [];
}

class SignUpSuccess extends SignUpState {
  final String message;

  const SignUpSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class SignUpFailure extends SignUpState {
  final String message;

  const SignUpFailure(this.message);

  @override
  List<Object> get props => [message];
}

class SignUpProcess extends SignUpState {
  @override
  List<Object> get props => [];
}
