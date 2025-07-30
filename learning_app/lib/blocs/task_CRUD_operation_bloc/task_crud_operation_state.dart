part of 'task_crud_operation_bloc.dart';

abstract class TaskCrudOperationState extends Equatable {
  const TaskCrudOperationState();

  @override
  List<Object> get props => [];
}

//general initial state
final class TaskCrudOperationInitial extends TaskCrudOperationState {
  @override
  List<Object> get props => [];
}

//this is for Creating Task
final class TaskCrudOperationLoading extends TaskCrudOperationState {
  @override
  List<Object> get props => [];
}

//Task has been loaded state
final class TaskCrudOperationLoaded extends TaskCrudOperationState {
  final String message;

  const TaskCrudOperationLoaded(this.message);

  @override
  List<Object> get props => [message];
}

//class to get task
final class   TasksState extends TaskCrudOperationState {
  final List<Task> pendingTasks;
  final List<Task> completedTasks;
  final List<Task> overdueTasks;
  final String userId;
  final double progress;

  const TasksState({
    this.pendingTasks = const <Task>[],
    this.completedTasks = const <Task>[],
    this.overdueTasks = const <Task>[],
    required this.userId,
    required this.progress,
  });

  @override
  List<Object> get props => [
        pendingTasks,
        completedTasks,
        overdueTasks,
        userId,
        progress,
      ];
}

//general failure message for all fail operation
final class TaskCrudOperationFailure extends TaskCrudOperationState {
  final String message;

  const TaskCrudOperationFailure(this.message);

  @override
  List<Object> get props => [message];
}

//update task list state
class UpdateTasksState extends TaskCrudOperationEvent {
  final List<Task> pendingTasks;
  final List<Task> completedTasks;
  final List<Task> overdueTasks;
  final String userId;
  final double progress;

  const UpdateTasksState({
    required this.pendingTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.userId,
    required this.progress,
  });

  @override
  List<Object> get props => [
        pendingTasks,
        completedTasks,
        overdueTasks,
        userId,
        progress,
      ];
}
