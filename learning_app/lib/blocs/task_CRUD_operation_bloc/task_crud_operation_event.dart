part of 'task_crud_operation_bloc.dart';

abstract class TaskCrudOperationEvent extends Equatable {
  const TaskCrudOperationEvent();

  @override
  List<Object> get props => [];
}

class CreateTask extends TaskCrudOperationEvent {
  final Task task;
  final String userId;

  const CreateTask(this.task, this.userId);

  @override
  List<Object> get props => [task, userId];
}

class DeleteTask extends TaskCrudOperationEvent {
  final String userId;
  final String taskId;
  final int notificationId;

  const DeleteTask(this.taskId, this.userId, this.notificationId);

  @override
  List<Object> get props => [taskId, userId, notificationId];
}

class UpdateTaskStatus extends TaskCrudOperationEvent {
  final String userId;
  final String taskId;
  final bool isDone;
  final int notificationId;

  const UpdateTaskStatus(
      this.taskId, this.isDone, this.userId, this.notificationId);

  @override
  List<Object> get props => [
        taskId,
        isDone,
        userId,
        notificationId,
      ];
}

class UpdateTask extends TaskCrudOperationEvent {
  final Task updatedTask;
  final String userId;

  const UpdateTask(this.updatedTask, this.userId);

  @override
  List<Object> get props => [updatedTask, userId];
}

class FetchTasks extends TaskCrudOperationEvent {
  final String userId;

  const FetchTasks({required this.userId});

  @override
  List<Object> get props => [userId];
}
