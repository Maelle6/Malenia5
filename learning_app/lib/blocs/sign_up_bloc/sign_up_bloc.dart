import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/user_repository.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final UserRepository _userRepository;

  SignUpBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SignUpInitial()) {
    // Sign up
    on<SignUpRequired>((event, emit) async {
      emit(SignUpProcess());
      try {
        MyUser user = await _userRepository.signUp(event.user, event.password);
        await _userRepository.setUserData(user);
        emit(const SignUpSuccess(
            'Account created successfully, You are now a member'));
      } on FirebaseAuthException catch (e) {
        log('SignUp Failure: ${e.code} - ${e.message}');
        emit(SignUpFailure(e.message ?? 'An unknown error occurred.'));
      } catch (e) {
        log('SignUp Failure: ${e.toString()}');
        emit(const SignUpFailure(
            'An unknown error occurred. Please try again.'));
      }
    });
    //end
  }
}
