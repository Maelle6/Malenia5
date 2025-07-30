// lib/services/supabase_service.dart
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final supabase = Supabase.instance.client;

  Future<void> insertUserToSupabase(Map<String, dynamic> userData) async {
    await supabase.from('userprofile').insert(userData);
  }

  Future<void> insertSubscriptionToSupabase(
      Map<String, dynamic> subscriptionData) async {
    await supabase.from('subscriptions').insert(subscriptionData);
  }

  Future<void> updateUserInSupabase(
      String id, Map<String, dynamic> userData) async {
    await supabase.from('userprofile').update(userData).eq('id', id);
  }

  Future<void> deleteUserFromSupabase(String userId) async {
    await supabase.from('users').delete().eq('id', userId);
  }

  // ✅ New method to delete related subscriptions
  Future<void> deleteSubscriptionsForUser(String userId) async {
    await supabase.from('subscriptions').delete().eq('userId', userId);
  }

  Future<void> upsertUserToSupabase(Map<String, dynamic> userData) async {
    try {
      await supabase.from('userprofile').upsert(userData);
    } catch (e) {
      log('SupabaseService.upsertUserToSupabase error: $e');
      rethrow;
    }
  }
}
