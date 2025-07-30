import 'package:deadline_repository/deadline_repository.dart';

abstract class DeadlineRepository {
  //Create Task and save to firestore
  Future<Deadline> createDeadline(Deadline deadline, String userId);

  //Stream Get Task From Firestore
  Stream<List<Deadline>> getDeadlineStream(String userId);

  //Deleting Task from Firestore
  Future<void> deleteDeadline(String deadlineId);
  
  //Update Deadline status
  Future<void> updateDeadlineStatus(String deadlineId, bool isDone);
}
