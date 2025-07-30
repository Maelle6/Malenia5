import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        await _mirrorUserToSupabase(user);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, Map<String, dynamic> userData) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        await _mirrorUserToSupabase(user, userData);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _mirrorUserToSupabase(fb_auth.User user,
      [Map<String, dynamic>? userData]) async {
    // Pull from Firestore or userData map
    final uid = user.uid;

    final Map<String, dynamic> userProfile = {
      'id': uid,
      'email': user.email,
      'companyName': userData?['companyName'] ?? '',
      'companyAddress': userData?['companyAddress'] ?? '',
      'companyIndustry': userData?['companyIndustry'] ?? '',
      'companyLogo': userData?['companyLogo'] ?? '',
      'name': userData?['name'] ?? '',
      'role': userData?['role'] ?? '',
    };

    // Upsert into Supabase users table
    await _supabase.from('users').upsert(userProfile);

    // Also sync subscription if passed
    if (userData?['subscription'] != null) {
      final subscription = userData!['subscription'];
      await _supabase.from('subscriptions').upsert({
        'user_id': uid,
        'package': subscription['package'],
        'subscription_date': subscription['subscriptionDate'],
        'expiry_date': subscription['expiryDate'],
        'modules': subscription['modules'],
      });
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // Status is automatically set to 'online' by the trigger
    } catch (error) {
      print('Sign-in error: $error');
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      // Status is automatically set to 'offline' by the trigger
    } catch (error) {
      print('Sign-out error: $error');
    }
  }
}
