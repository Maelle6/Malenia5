import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../deadline_repository.dart';

class FirebaseDeadlineRepository implements DeadlineRepository {
  final deadlinesCollections =
      FirebaseFirestore.instance.collection('deadlines');

  //Create deadline
  @override
  Future<Deadline> createDeadline(Deadline deadline, String userId) async {
    try {
      // Step 1: Generate a unique notification ID using UUID
      const uuid = Uuid();
      final notificationId =
          uuid.v4().hashCode.abs(); // Use hashCode and ensure it's positive

      // Create a new Task instance with updated createdAt and taskId
      final docRef = deadlinesCollections.doc(); // Get a new document reference
      // Create a new Task with updated fields
      final newDeadline = deadline.copyWith(
        userId: userId,
        deadlineId: docRef.id, // Automatically generated task ID from Firestore
        createdAt: DateTime.now(),
        notificationId: notificationId,
      );
      // Convert the Task to an entity and save it to Firestore
      await docRef.set(newDeadline.toEntity().toDocument());
      developer.log('Task created: $newDeadline');
      return newDeadline;
    } catch (e) {
      developer.log('Error creating task: $e');
      rethrow; // Propagate the error
    }
  }

  // Stream for real-time deadline updates
  @override
  Stream<List<Deadline>> getDeadlineStream(String userId) {
    return deadlinesCollections
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots() // Firestore snapshot stream
        .map((snapshot) {
      print("Fetched ${snapshot.docs.length} deadlines");
      return snapshot.docs
          .map(
              (e) => Deadline.fromEntity(DeadlineEntity.fromDocument(e.data())))
          .toList();
    });
  }

  //Delete Deadline
  @override
  Future<void> deleteDeadline(String deadlineId) async {
    try {
      // Attempt to delete the task document with the given taskId
      await deadlinesCollections.doc(deadlineId).delete();
      developer.log(
          'Deadline with DeadlineId $deadlineId has been deleted successfully');
    } catch (e) {
      developer.log('Error in deleteTask: ${e.toString()}');
      rethrow; // Rethrow the exception to propagate the error if needed
    }
  }

  //Update Task Status (mark Task As Done)
  @override
  Future<void> updateDeadlineStatus(String deadlineId, bool isDone) async {
    try {
      // Update the `isDone` field of the task document with the provided `taskId`
      await deadlinesCollections.doc(deadlineId).update({'isDone': isDone});
      developer.log(
          'Task with taskId $deadlineId has been updated to isDone: $isDone');
    } catch (e) {
      developer.log('Error in updateTaskStatus: ${e.toString()}');
      rethrow;
    }
  }
}
