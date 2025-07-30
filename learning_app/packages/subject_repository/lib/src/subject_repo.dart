import 'package:subject_repository/src/models/subject.dart';

abstract class SubjectRepository {
  //Create Subject and save to firestore
  Future<Subject> createSubject(Subject subject, String userId);

  //Stream Get Subject From Firestore
  Stream<List<Subject>> getSubjectStream(String userId);

  //Deleting Subject from Firestore
  Future<void> deleteSubject(String subjectId);

  //Editing Subject From Firestore
  Future<void> updateSubject(Subject updatedSubject);
}
