import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_repository/task_repository.dart';
import 'package:uuid/uuid.dart';

class FirebaseTaskRepository implements TaskRepository {
  final tasksCollections = FirebaseFirestore.instance.collection('tasks');

  //Create Task
  @override
  Future<Task> createTask(Task task, String userId) async {
    try {
      // Step 1: Generate a unique notification ID using UUID
      const uuid = Uuid();
      final notificationId =
          uuid.v4().hashCode.abs(); // Use hashCode and ensure it's positive

      // Step 2: Get a Firestore document reference
      final docRef = tasksCollections.doc();

      // Step 3: Create a new Task instance with all required fields
      final newTask = task.copyWith(
        userId: userId,
        taskId: docRef.id, // Automatically generated task ID from Firestore
        createdAt: DateTime.now(),
        notificationId: notificationId, // Ensure this is assigned synchronously
      );

      // Step 4: Convert the Task to an entity and save it to Firestore
      await docRef.set(newTask.toEntity().toDocument());
      developer.log('Task created: $newTask');

      // Step 5: Return the newly created task with the notification ID
      return newTask;
    } catch (e) {
      developer.log('Error creating task: $e');
      rethrow; // Propagate the error
    }
  }

  // Stream for real-time task updates
  @override
  Stream<List<Task>> getTaskStream(String userId) {
    return tasksCollections
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots() // Firestore snapshot stream
        .map((snapshot) {
      print("Fetched ${snapshot.docs.length} tasks");
      return snapshot.docs
          .map((e) => Task.fromEntity(TaskEntity.fromDocument(e.data())))
          .toList();
    });
  }

  //Delete Task
  @override
  Future<void> deleteTask(String taskId) async {
    try {
      // Attempt to delete the task document with the given taskId
      await tasksCollections.doc(taskId).delete();
      developer.log('Task with taskId $taskId has been deleted successfully');
    } catch (e) {
      developer.log('Error in deleteTask: ${e.toString()}');
      rethrow; // Rethrow the exception to propagate the error if needed
    }
  }

  //Update Task Status (mark Task As Done)
  @override
  Future<void> updateTaskStatus(String taskId, bool isDone) async {
    try {
      // Update the `isDone` field of the task document with the provided `taskId`
      await tasksCollections.doc(taskId).update({'isDone': isDone});
      developer
          .log('Task with taskId $taskId has been updated to isDone: $isDone');
    } catch (e) {
      developer.log('Error in updateTaskStatus: ${e.toString()}');
      rethrow;
    }
  }

  // Editing the task Object  to change several fields at once
  @override
  Future<void> updateTask(Task updatedTask) async {
    try {
      await tasksCollections.doc(updatedTask.taskId).update(
            updatedTask.toEntity().toDocument(),
          );
      developer.log(
          'Task with taskId ${updatedTask.taskId} has been updated successfully');
    } catch (e) {
      developer.log('Error in updateTask: ${e.toString()}');
      rethrow;
    }
  }
}
