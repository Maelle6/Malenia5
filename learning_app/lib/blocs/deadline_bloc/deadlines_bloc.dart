import 'dart:async';
import 'package:deadline_repository/deadline_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:learning_app/services/notification_service.dart';

part 'deadlines_event.dart';
part 'deadlines_state.dart';

class DeadlineBloc extends Bloc<DeadlinesEvent, DeadlinesState> {
  final DeadlineRepository _deadlineRepository;
  StreamSubscription<List<Deadline>>? _deadlineStreamSubscription;

  DeadlineBloc({required DeadlineRepository deadlineRepository})
      : _deadlineRepository = deadlineRepository,
        super(DeadlinesInitial()) {
    // Handle FetchTasks event
    on<FetchDeadlines>((event, emit) {
      _deadlineStreamSubscription?.cancel(); // Cancel any existing subscription
      _deadlineStreamSubscription = _deadlineRepository
          .getDeadlineStream(event.userId)
          .listen((deadlines) {
        _categorizeAndEmitDeadlines(deadlines, event.userId);
      }, onError: (error) {
        emit(DeadlineOperationFailure('Error fetching tasks: $error'));
      });
    });

    // Handle UpdateTasksState event
    on<UpdateDeadlinesState>((event, emit) async {
      emit(DeadlineList(
        upcomingDeadlines: event.upcomingDeadlines,
        passDueDeadlines: event.passDueDeadlines,
        userId: event.userId,
      ));
    });

    // Handle CreateTask event
    on<CreateDeadline>((event, emit) async {
      emit(DeadlineLoading());
      try {
        final createdDeadline = await _deadlineRepository.createDeadline(
            event.deadline, event.userId);
        // Schedule notifications using the createdTask
        await NotificationService()
            .scheduleOneDayBeforeReminderForDeadline(createdDeadline);
        await NotificationService()
            .scheduleSameDayReminderForDeadline(createdDeadline);
        add(FetchDeadlines(userId: event.userId)); // Refresh task stream
        emit(const DeadlineLoaded('Upcoming Deadlines created successfully'));
      } catch (e) {
        emit(DeadlineOperationFailure('Failed to create Deadlines: $e'));
      }
    });

    // Handle DeleteTask event
    on<DeleteDeadline>((event, emit) async {
      emit(DeadlineLoading());
      try {
        await NotificationService().cancelNotification(event.notificationId);
        await _deadlineRepository.deleteDeadline(event.deadlineId);
        add(FetchDeadlines(userId: event.userId)); // Refresh task stream
        emit(const DeadlineLoaded('Deadline deleted successfully'));
      } catch (e) {
        emit(DeadlineOperationFailure('Failed to delete Deadline: $e'));
      }
    });

    // Handle UpdateTaskStatus event
    on<UpdateDeadlineStatus>((event, emit) async {
      emit(DeadlineLoading());
      try {
        await _deadlineRepository.updateDeadlineStatus(
            event.deadlineId, event.isDone);
        add(FetchDeadlines(userId: event.userId)); // Refresh task stream
        emit(const DeadlineLoaded('Deadline status updated successfully'));
      } catch (e) {
        emit(DeadlineOperationFailure('Failed to update Deadline status: $e'));
      }
    });
  }
  // Helper method to categorize and emit tasks
  void _categorizeAndEmitDeadlines(List<Deadline> deadlines, String userId) {
    List<Deadline> upcoming = [];
    List<Deadline> pastDue = [];

    for (var deadline in deadlines) {
      if (deadline.dueDate
              .isBefore(DateTime.now().add(const Duration(days: -1))) &&
          !deadline.isDone) {
        pastDue.add(deadline);
      } else {
        upcoming.add(deadline);
      }
    }

    add(UpdateDeadlinesState(
      upcomingDeadlines: upcoming,
      passDueDeadlines: pastDue,
      userId: userId,
    ));
  }

  @override
  Future<void> close() {
    _deadlineStreamSubscription?.cancel();
    return super.close();
  }
}
