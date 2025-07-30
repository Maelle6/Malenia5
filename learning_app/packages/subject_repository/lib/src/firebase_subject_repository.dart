import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:subject_repository/subject_repository.dart';

class FirebaseSubjectRepository implements SubjectRepository {
  final subjectsCollections = FirebaseFirestore.instance.collection('subjects');

  //Create Subject
  @override
  Future<Subject> createSubject(Subject subject, String userId) async {
    try {
      // Step 1: Generate a unique notification ID using UUID
      //const uuid = Uuid();
      //final notificationId =
      //   uuid.v4().hashCode.abs(); // Use hashCode and ensure it's positive

      // Step 2: Get a Firestore document reference
      final docRef = subjectsCollections.doc();

      // Step 3: Create a new Subject instance with all required fields
      final newSubject = subject.copyWith(
        userId: userId,
        subjectId:
            docRef.id, // Automatically generated subject ID from Firestore
        // notificationId: notificationId, // Ensure this is assigned synchronously
      );

      // Step 4: Convert the Subject to an entity and save it to Firestore
      await docRef.set(newSubject.toEntity().toDocument());
      developer.log('Subject created: $newSubject');

      // Step 5: Return the newly created Subject with the notification ID
      return newSubject;
    } catch (e) {
      developer.log('Error creating subject: $e');
      rethrow; // Propagate the error
    }
  }

  // Stream for real-time task updates
  @override
  Stream<List<Subject>> getSubjectStream(String userId) {
    print('Querying subjects for userId: $userId');
    return subjectsCollections
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      print("Fetched ${snapshot.docs.length} subjects");

      final subjects = snapshot.docs
          .map((doc) {
            final docData = doc.data();
            print('Raw Document Data: $docData');

            try {
              final subject =
                  Subject.fromEntity(SubjectEntity.fromDocument(docData));
              print('Converted Subject: $subject');
              return subject;
            } catch (e) {
              print('Error converting document to Subject: $e');
              print('Problematic document data: $docData');
              return null;
            }
          })
          .whereType<Subject>()
          .toList();

      print('Converted Subjects Count: ${subjects.length}');
      return subjects;
    });
  }

  //Delete Subject
  @override
  Future<void> deleteSubject(String subjectId) async {
    try {
      // Attempt to delete the subject document with the given subjectId
      await subjectsCollections.doc(subjectId).delete();
      developer
          .log('Task with taskId $subjectId has been deleted successfully');
    } catch (e) {
      developer.log('Error in deleteSubject: ${e.toString()}');
      rethrow; // Rethrow the exception to propagate the error if needed
    }
  }

  // Editing the subject Object  to change several fields at once
  @override
  Future<void> updateSubject(Subject updatedSubject) async {
    try {
      await subjectsCollections.doc(updatedSubject.subjectId).update(
            updatedSubject.toEntity().toDocument(),
          );
      developer.log(
          'Task with taskId ${updatedSubject.subjectId} has been updated successfully');
    } catch (e) {
      developer.log('Error in updateSubject: ${e.toString()}');
      rethrow;
    }
  }
}
