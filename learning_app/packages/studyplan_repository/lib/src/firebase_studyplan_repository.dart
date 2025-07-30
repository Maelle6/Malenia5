import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studyplan_repository/studyplan_repository.dart';

class FirebaseStudyplanRepository implements StudyplanRepository {
  final studyplanCollections =
      FirebaseFirestore.instance.collection('studyplan');

  //Create Studyplan
  @override
  Future<Studyplan> createStudyplan(Studyplan studyplan, String userId) async {
    try {
      // Step 2: Get a Firestore document reference
      final docRef = studyplanCollections.doc();

      // Step 3: Create a new Studyplan instance with all required fields
      final newStudyplan = studyplan.copyWith(
        userId: userId,
        studyplanId:
            docRef.id, // Automatically generated task ID from Firestore
      );

      // Step 4: Convert the Task to an entity and save it to Firestore
      await docRef.set(newStudyplan.toEntity().toDocument());
      developer.log('Studyplan created: $newStudyplan');

      // Step 5: Return the newly created task with the notification ID
      return newStudyplan;
    } catch (e) {
      developer.log('Error creating Studyplan: $e');
      rethrow; // Propagate the error
    }
  }

  // Stream for real-time task updates
  @override
  Stream<List<Studyplan>> getStudyplanStream(String userId) {
    return studyplanCollections
        .where('userId', isEqualTo: userId)
        .snapshots() // Firestore snapshot stream
        .map((snapshot) {
      print("Fetched ${snapshot.docs.length} studyplan");
      return snapshot.docs
          .map((e) =>
              Studyplan.fromEntity(StudyplanEntity.fromDocument(e.data())))
          .toList();
    });
  }

  //Delete Task
  @override
  Future<void> deleteStudyplan(String studyplanId) async {
    try {
      // Attempt to delete the task document with the given taskId
      await studyplanCollections.doc(studyplanId).delete();
      developer.log(
          'Task with studyplanId $studyplanId has been deleted successfully');
    } catch (e) {
      developer.log('Error in deleteStudyplan: ${e.toString()}');
      rethrow; // Rethrow the exception to propagate the error if needed
    }
  }

  // //Update Task Status (mark Task As Done)
  // @override
  // Future<void> updateTaskStatus(String taskId, bool isDone) async {
  //   try {
  //     // Update the `isDone` field of the task document with the provided `taskId`
  //     await tasksCollections.doc(taskId).update({'isDone': isDone});
  //     developer
  //         .log('Task with taskId $taskId has been updated to isDone: $isDone');
  //   } catch (e) {
  //     developer.log('Error in updateTaskStatus: ${e.toString()}');
  //     rethrow;
  //   }
  // }

  // Editing the task Object  to change several fields at once
  @override
  Future<void> updateStudyplan(Studyplan updatedStudyplan) async {
    try {
      await studyplanCollections.doc(updatedStudyplan.studyplanId).update(
            updatedStudyplan.toEntity().toDocument(),
          );
      developer.log(
          'Task with studyplanId ${updatedStudyplan.studyplanId} has been updated successfully');
    } catch (e) {
      developer.log('Error in updateStudyplan: ${e.toString()}');
      rethrow;
    }
  }
}
