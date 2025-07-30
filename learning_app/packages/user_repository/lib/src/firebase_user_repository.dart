import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user_repository/src/sync_service.dart';
import 'entities/entities.dart';
import 'models/my_user.dart';
import 'user_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    SyncService? syncService,
    SupabaseClient? supabaseClient,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _syncService = syncService,
        _supabaseClient = supabaseClient ?? Supabase.instance.client;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final SupabaseClient _supabaseClient;

  final usersCollections = FirebaseFirestore.instance.collection('users');

  final SyncService? _syncService; // <-- add this

  //Stream user
  @override
  Stream<firebase_auth.User?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser;
      return user;
    });
  }

  //Sign up
  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      // Create account in Firebase Auth
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: myUser.email,
        password: password,
      );

      // Update UID
      myUser = myUser.copyWith(id: user.user!.uid);

      // Save user data to Firestore
      await setUserData(myUser);

      // Sync to Supabase
      if (_syncService != null) {
        await _syncService.upsertUserToSupabase(myUser.toEntity().toDocument());
      }

      return myUser;
    } catch (e) {
      log('signUp error: $e');
      rethrow;
    }
  }

  //Sign in
  @override
  Future<void> signIn(String email, String password) async {
    try {
      // Firebase sign-in
      UserCredential credential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      final user = await getMyUser(credential.user!.uid);

      // Sync to Supabase (optional, safe to repeat)
      if (_syncService != null) {
        await _syncService.upsertUserToSupabase(user.toEntity().toDocument());
        // ✅ Also sync their subscriptions
        await syncUserSubscriptions(user.id);
      }
    } catch (e) {
      log('signIn error: $e');
      rethrow;
    }
  }

  //Log out
  @override
  Future<void> logOut() async {
    try {
      // Create a list of sign-out futures
      final signOutFutures = [
        _firebaseAuth.signOut(),
        _supabaseClient.auth.signOut(),
      ];

      // Await them both concurrently
      await Future.wait(signOutFutures);
    } catch (e) {
      // Handle or log any potential errors during sign-out
      print('Error during logout: $e');
      // You might want to rethrow the exception or handle it as needed
      rethrow;
    }
  }

  //Reset password
  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // Set user data in Firebase and Supabase
  @override
  Future<void> setUserData(MyUser user) async {
    try {
      await usersCollections.doc(user.id).set(user.toEntity().toDocument());

      if (_syncService != null) {
        await _syncService.upsertUserToSupabase(user.toEntity().toDocument());
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  //get user data
  @override
  Future<MyUser> getMyUser(String myUserId) async {
    try {
      final doc = await usersCollections.doc(myUserId).get();
      final data = doc.data();

      if (data == null) {
        throw Exception('User not found in Firestore');
      }

      return MyUser.fromEntity(MyUserEntity.fromDocument(data));
    } catch (e) {
      log('getMyUser error: $e');
      rethrow;
    }
  }

  //check if user is registered or not
  @override
  Future<bool> isUserRegistered(String email) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return userSnapshot.docs.isNotEmpty; // Returns true if user exists
  }

  @override
  Future<MyUser?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Force account picker

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final firebase_auth.User? user = userCredential.user;

      if (user != null) {
        final myUser = MyUser(
          id: user.uid,
          email: user.email!,
          username: user.displayName ?? '',
          profileImage: user.photoURL,
        );

        // Check if user already exists in Firestore
        final doc = await usersCollections.doc(myUser.id).get();
        if (!doc.exists) {
          await setUserData(myUser);

          // Sync to Supabase
          if (_syncService != null) {
            await _syncService
                .upsertUserToSupabase(myUser.toEntity().toDocument());
          }
        }

        // ✅ Also sync their subscriptions
        await syncUserSubscriptions(user.uid);

        return myUser;
      }

      return null;
    } catch (e) {
      log('Google Sign-In error: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(MyUser user) async {
    try {
      // Delete from Firebase Auth
      await _firebaseAuth.currentUser?.delete();

      // Optionally delete from Firestore
      await usersCollections.doc(user.id).delete();

      // Delete from Supabase if sync service exists
      if (_syncService != null) {
        await _syncService.deleteUserFromSupabase(user.id);
        await _syncService
            .deleteSubscriptionsForUser(user.id); // Optional, but ideal
      }
    } catch (e) {
      log('deleteUser error: $e');
      rethrow;
    }
  }

  @override
  Future<void> syncUserSubscriptions(String userId) async {
    try {
      final activeDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('subscription')
          .doc('active')
          .get();

      if (activeDoc.exists) {
        final data = activeDoc.data();
        if (data != null) {
          data['user_id'] = userId; // Link to Supabase user
          await _syncService?.insertSubscriptionToSupabase(data);
        }
      } else {
        log('No active subscription found for user: $userId');
      }
    } catch (e) {
      log('syncUserSubscriptions error: $e');
      rethrow;
    }
  }
}
