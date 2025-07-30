import 'package:firebase_auth/firebase_auth.dart';
import '../user_repository.dart';

abstract class UserRepository {
  //Stream user
  Stream<User?> get user;

  //Sign in
  Future<void> signIn(String email, String password);

  //Log out
  Future<void> logOut();

  //Sign up
  Future<MyUser> signUp(MyUser myUser, String password);

  //reset password
  Future<void> resetPassword(String email);

  //Set user data
  Future<void> setUserData(MyUser user);

  //Get user Data
  Future<MyUser> getMyUser(String myUserId);

  //check if user has an account for sending a reset password email
  Future<bool> isUserRegistered(String email);
  
  //Google Sign in
  Future<MyUser?> signInWithGoogle();
}
