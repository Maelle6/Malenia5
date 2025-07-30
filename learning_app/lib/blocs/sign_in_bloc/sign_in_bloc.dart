import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_repository/user_repository.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final UserRepository _userRepository;

  SignInBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SignInInitial()) {
    //Sign in
    on<SignInRequired>((event, emit) async {
      emit(SignInProcess());

      try {
        // Try Firebase
        await _userRepository.signIn(event.email, event.password);

        // Firebase success
        emit(const SignInSuccess('Login Successful (Firebase)'));

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({'lastActive': Timestamp.now()}, SetOptions(merge: true));
        return; // ✅ exit here, don’t continue to Supabase
      } catch (e) {
        log('Firebase login failed: $e');
        // Don't emit here — fallback to Supabase
      }

      try {
        final SupabaseClient _supabase = Supabase.instance.client;

        // Try Supabase
        final response = await Supabase.instance.client.auth
            .signInWithPassword(email: event.email, password: event.password);

        if (response.user != null) {
          try {
            debugPrint('🔁 Attempting to update loginstatus...');

            final updateResponse = await _supabase
                .from('employees')
                .update({'loginstatus': 'online'})
                .eq('supabase_user_id', response.user!.id)
                .select();

            debugPrint('📝 Update response: $updateResponse');
          } catch (updateError) {
            debugPrint('❗ Error while updating loginstatus: $updateError');
          }

          emit(const SignInSuccess('Login Successful (Supabase)'));
        } else {
          emit(const SignInFailure('Supabase login failed. User is null.'));
        }
      } on AuthException catch (e) {
        log('Supabase AuthException: ${e.message}');
        emit(SignInFailure(e.message));
      } catch (e) {
        log('Unknown Supabase login error: $e');
        emit(const SignInFailure('Supabase login failed.'));
      }
    });

    //Sign out
    on<SignOutRequired>((event, emit) async {
      final supabaseUser = Supabase.instance.client.auth.currentUser;

      if (supabaseUser != null) {
        try {
          debugPrint(
              '🔁 Attempting to update loginstatus to offline for user: ${supabaseUser.id}');

          final updateResponse = await Supabase.instance.client
              .from('employees')
              .update({'loginstatus': 'offline'})
              .eq('supabase_user_id', supabaseUser.id)
              .select();

          debugPrint('📝 Sign-out update response: $updateResponse');
        } catch (e, stack) {
          debugPrint('❌ Error while updating loginstatus on sign-out: $e');
          debugPrint('📌 StackTrace: $stack');
        }
      } else {
        debugPrint('⚠️ No Supabase user found during sign-out.');
      }

      await _userRepository.logOut();
    });

    //Reset Password
    on<ResetPasswordRequired>((event, emit) async {
      emit(ResetPasswordInProcess());
      try {
        // Check if the user is registered
        final isRegistered =
            await _userRepository.isUserRegistered(event.email);

        if (!isRegistered) {
          emit(const ResetPasswordFailure('No user found for that email.'));
          return; // Exit early if the user is not found
        }
        await _userRepository.resetPassword(event.email);
        emit(const ResetPasswordSuccess(
            'Password reset email sent successfully.'));
      } on FirebaseAuthException catch (e) {
        log('Error code: ${e.code} - ${e.message}');
        emit(ResetPasswordFailure(
            e.message ?? 'An unknown Error has occurred.'));
      } catch (e) {
        log('General error: $e');
        emit(const ResetPasswordFailure('An unknown error occurred.'));
      }
    });

    //Google Sign in
    on<GoogleSignInRequired>((event, emit) async {
      emit(SignInProcess());
      try {
        emit(SignInProcess());
        final user = await _userRepository.signInWithGoogle();
        if (user != null) {
          // Check if the user exists in Firestore by calling isUserRegistered
          final isRegistered =
              await _userRepository.isUserRegistered(user.email);
          if (!isRegistered) {
            // Set the user data if they are not yet in Firestore
            await _userRepository.setUserData(user);
          }
          emit(const SignInSuccess('Login Successful'));
        } else {
          emit(const SignInFailure('Sign-In was canceled.'));
        }
      } on FirebaseAuthException catch (e) {
        log('SignUp Failure: ${e.code} - ${e.message}');
        emit(SignInFailure(e.message ?? 'An unknown error occurred.'));
      } catch (e) {
        log(e.toString());
        emit(const SignInFailure('Failed to sign in with Google.'));
      }
    });
    //end
  }
}
