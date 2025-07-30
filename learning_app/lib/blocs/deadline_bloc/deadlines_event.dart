part of 'deadlines_bloc.dart';

abstract class DeadlinesEvent extends Equatable {
  const DeadlinesEvent();

  @override
  List<Object> get props => [];
}

class CreateDeadline extends DeadlinesEvent {
  final Deadline deadline;
  final String userId;

  const CreateDeadline(this.deadline, this.userId);

  @override
  List<Object> get props => [deadline, userId];
}

class DeleteDeadline extends DeadlinesEvent {
  final String userId;
  final String deadlineId;
  final int notificationId;

  const DeleteDeadline(this.deadlineId, this.userId, this.notificationId);

  @override
  List<Object> get props => [deadlineId, userId, notificationId];
}

class UpdateDeadlineStatus extends DeadlinesEvent {
  final String userId;
  final String deadlineId;
  final bool isDone;

  const UpdateDeadlineStatus(this.userId, this.deadlineId, this.isDone);

  @override
  List<Object> get props => [userId, deadlineId, isDone];
}

class FetchDeadlines extends DeadlinesEvent {
  final String userId;

  const FetchDeadlines({required this.userId});

  @override
  List<Object> get props => [userId];
}
