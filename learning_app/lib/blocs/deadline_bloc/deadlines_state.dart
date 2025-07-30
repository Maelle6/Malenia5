part of 'deadlines_bloc.dart';

abstract class DeadlinesState extends Equatable {
  const DeadlinesState();

  @override
  List<Object> get props => [];
}

final class DeadlinesInitial extends DeadlinesState {
  @override
  List<Object> get props => [];
}

//this is for Creating Task
final class DeadlineLoading extends DeadlinesState {
  @override
  List<Object> get props => [];
}

//Task has been loaded state
final class DeadlineLoaded extends DeadlinesState {
  final String message;

  const DeadlineLoaded(this.message);

  @override
  List<Object> get props => [message];
}

//class to get task
final class DeadlineList extends DeadlinesState {
  final List<Deadline> upcomingDeadlines;
  final List<Deadline> passDueDeadlines;
  final String userId;

  const DeadlineList({
    this.upcomingDeadlines = const <Deadline>[],
    this.passDueDeadlines = const <Deadline>[],
    required this.userId,
  });

  @override
  List<Object> get props => [
        upcomingDeadlines,
        passDueDeadlines,
        userId,
      ];
}

//general failure message for all fail operation
final class DeadlineOperationFailure extends DeadlinesState {
  final String message;

  const DeadlineOperationFailure(this.message);

  @override
  List<Object> get props => [message];
}

//update task list state
final class UpdateDeadlinesState extends DeadlinesEvent {
  final List<Deadline> upcomingDeadlines;
  final List<Deadline> passDueDeadlines;
  final String userId;

  const UpdateDeadlinesState({
    required this.upcomingDeadlines,
    required this.passDueDeadlines,
    required this.userId,
  });

  @override
  List<Object> get props => [
        upcomingDeadlines,
        passDueDeadlines,
        userId,
      ];
}
