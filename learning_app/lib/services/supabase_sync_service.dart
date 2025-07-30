// lib/services/supabase_sync_service.dart
import 'package:learning_app/services/supabase_service.dart';
import 'package:user_repository/src/sync_service.dart';

class SupabaseSyncService implements SyncService {
  final SupabaseService _supabaseService = SupabaseService();

  @override
  Future<void> insertUserToSupabase(Map<String, dynamic> userData) {
    return _supabaseService.insertUserToSupabase(userData);
  }

  @override
  Future<void> insertSubscriptionToSupabase(Map<String, dynamic> subData) {
    return _supabaseService.insertSubscriptionToSupabase(subData);
  }

  @override
  Future<void> deleteUserFromSupabase(String userId) async {
    await _supabaseService.deleteUserFromSupabase(userId);
  }

  // ✅ New method
  @override
  Future<void> deleteSubscriptionsForUser(String userId) {
    return _supabaseService.deleteSubscriptionsForUser(userId);
  }

  @override
  Future<void> updateUserInSupabase(
      String userId, Map<String, dynamic> userData) {
    return _supabaseService.updateUserInSupabase(userId, userData);
  }

  @override
  Future<void> upsertUserToSupabase(Map<String, dynamic> userData) async {
    return _supabaseService.upsertUserToSupabase(userData);
  }
}
