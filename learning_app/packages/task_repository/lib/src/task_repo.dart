import 'package:task_repository/src/models/task.dart';

abstract class TaskRepository {
  //Create Task and save to firestore
  Future<Task> createTask(Task task, String userId);

  //Stream Get Task From Firestore
  Stream<List<Task>> getTaskStream(String userId);

  //Deleting Task from Firestore
  Future<void> deleteTask(String taskId);

  //Updating the Task Status isDone From Firestore
  Future<void> updateTaskStatus(String taskId, bool isDone);

  //Editing Task From Firestore
  Future<void> updateTask(Task updatedTask);
}
