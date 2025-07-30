import 'package:studyplan_repository/src/models/studyplan.dart';

abstract class StudyplanRepository {
  //Create Studyplan and save to firestore
  Future<Studyplan> createStudyplan(Studyplan studyplan, String userId);

  //Stream Get Task From Firestore
  Stream<List<Studyplan>> getStudyplanStream(String userId);

  //Deleting Task from Firestore
  Future<void> deleteStudyplan(String studyplanId);

  //Updating the Task Status isDone From Firestore
  // Future<void> updateTaskStatus(String studyplanId, bool isDone);

  //Editing Task From Firestore
  Future<void> updateStudyplan(Studyplan updatedStudyplan);
}
