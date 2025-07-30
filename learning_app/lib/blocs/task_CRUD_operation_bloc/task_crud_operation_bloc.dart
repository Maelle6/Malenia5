import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:learning_app/services/notification_service.dart';
import 'package:task_repository/task_repository.dart';

part 'task_crud_operation_event.dart';
part 'task_crud_operation_state.dart';

class TaskCrudOperationBloc
    extends Bloc<TaskCrudOperationEvent, TaskCrudOperationState> {
  final TaskRepository _taskRepository;
  StreamSubscription<List<Task>>? _taskStreamSubscription;

  TaskCrudOperationBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        super(TaskCrudOperationInitial()) {
    // Handle FetchTasks event
    on<FetchTasks>((event, emit) {
      _taskStreamSubscription?.cancel(); // Cancel any existing subscription
      _taskStreamSubscription =
          _taskRepository.getTaskStream(event.userId).listen((tasks) {
        _categorizeAndEmitTasks(tasks, event.userId);
      }, onError: (error) {
        emit(TaskCrudOperationFailure('Error fetching tasks: $error'));
      });
    });

    // Handle UpdateTasksState event
    on<UpdateTasksState>((event, emit) async {
      emit(TasksState(
        pendingTasks: event.pendingTasks,
        completedTasks: event.completedTasks,
        overdueTasks: event.overdueTasks,
        userId: event.userId,
        progress: event.progress,
      ));
    });

    // Handle CreateTask event
    on<CreateTask>((event, emit) async {
      emit(TaskCrudOperationLoading());
      try {
        final createdTask =
            await _taskRepository.createTask(event.task, event.userId);

        // Schedule notifications using the createdTask
        await NotificationService().scheduleOneDayBeforeReminder(createdTask);
        await NotificationService().scheduleSameDayReminder(createdTask);
        add(FetchTasks(userId: event.userId)); // Refresh task stream
        emit(const TaskCrudOperationLoaded('Task created successfully'));
      } catch (e) {
        emit(TaskCrudOperationFailure('Failed to create task: $e'));
      }
    });

    // Handle DeleteTask event
    on<DeleteTask>((event, emit) async {
      emit(TaskCrudOperationLoading());
      try {
        await NotificationService().cancelNotification(event.notificationId);
        await _taskRepository.deleteTask(event.taskId);
        add(FetchTasks(userId: event.userId)); // Refresh task stream
        emit(const TaskCrudOperationLoaded('Task deleted successfully'));
      } catch (e) {
        emit(TaskCrudOperationFailure('Failed to delete task: $e'));
      }
    });

    // Handle UpdateTask event
    on<UpdateTask>((event, emit) async {
      emit(TaskCrudOperationLoading());
      try {
        await _taskRepository.updateTask(event.updatedTask);
        await NotificationService()
            .cancelNotification(event.updatedTask.notificationId);

        // Schedule notifications using the createdTask
        await NotificationService()
            .scheduleOneDayBeforeReminder(event.updatedTask);
        await NotificationService().scheduleSameDayReminder(event.updatedTask);

        add(FetchTasks(
            userId: event.updatedTask.userId)); // Refresh task stream
        emit(const TaskCrudOperationLoaded('Task updated successfully'));
      } catch (e) {
        emit(TaskCrudOperationFailure('Failed to update task: $e'));
      }
    });

    // Handle UpdateTaskStatus event
    on<UpdateTaskStatus>((event, emit) async {
      emit(TaskCrudOperationLoading());
      try {
        await _taskRepository.updateTaskStatus(event.taskId, event.isDone);
        await NotificationService().cancelNotification(event.notificationId);
        add(FetchTasks(userId: event.userId)); // Refresh task stream
        emit(const TaskCrudOperationLoaded('Task status updated successfully'));
      } catch (e) {
        emit(TaskCrudOperationFailure('Failed to update task status: $e'));
      }
    });
  }

  // Helper method to categorize and emit tasks
  void _categorizeAndEmitTasks(List<Task> tasks, String userId) {
    List<Task> completedTasks = [];
    List<Task> pendingTasks = [];
    List<Task> overdueTasks = [];

    for (var task in tasks) {
      if (task.isDone) {
        completedTasks.add(task);
      } else if (task.dueDate
              .isBefore(DateTime.now().add(const Duration(days: -1))) &&
          !task.isDone) {
        overdueTasks.add(task);
      } else {
        pendingTasks.add(task);
      }
    }

    // Calculate progress
    double progress = (completedTasks.length + pendingTasks.length) == 0
        ? 0.0
        : completedTasks.length / (completedTasks.length + pendingTasks.length);

    add(UpdateTasksState(
      pendingTasks: pendingTasks,
      completedTasks: completedTasks,
      overdueTasks: overdueTasks,
      userId: userId,
      progress: progress,
    ));
  }

  @override
  Future<void> close() {
    _taskStreamSubscription?.cancel();
    return super.close();
  }
}
