abstract class SyncService {
  Future<void> insertUserToSupabase(Map<String, dynamic> userData);
  Future<void> insertSubscriptionToSupabase(Map<String, dynamic> subData);
  Future<void> deleteUserFromSupabase(String userId);
  Future<void> deleteSubscriptionsForUser(String userId);
  Future<void> updateUserInSupabase(
      String id, Map<String, dynamic> userData); // 👈 Add this
  // ✅ ADD THIS LINE
  // ✅ ADD THIS
  Future<void> upsertUserToSupabase(Map<String, dynamic> userData);
}
