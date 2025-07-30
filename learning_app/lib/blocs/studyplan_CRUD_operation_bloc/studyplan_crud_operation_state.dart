part of 'studyplan_crud_operation_bloc.dart';

abstract class StudyplanCrudOperationState extends Equatable {
  const StudyplanCrudOperationState();

  @override
  List<Object> get props => [];
}

//general initial state
final class StudyplanCrudOperationInitial extends StudyplanCrudOperationState {
  @override
  List<Object> get props => [];
}

//this is for Creating Studyplan
final class StudyplanCrudOperationLoading extends StudyplanCrudOperationState {
  @override
  List<Object> get props => [];
}

final class StudyplanCrudOperationLoaded extends StudyplanCrudOperationState {
  final String message;
  final List<Studyplan> studyplans; // Add this field

  const StudyplanCrudOperationLoaded(this.message, {this.studyplans = const []}); // Update constructor

  @override
  List<Object> get props => [message, studyplans];
}

// //class to get task
// final class   TasksState extends StudyplanCrudOperationState {
//   final List<Task> pendingTasks;
//   final List<Task> completedTasks;
//   final List<Task> overdueTasks;
//   final String userId;
//   final double progress;

//   const TasksState({
//     this.pendingTasks = const <Task>[],
//     this.completedTasks = const <Task>[],
//     this.overdueTasks = const <Task>[],
//     required this.userId,
//     required this.progress,
//   });

//   @override
//   List<Object> get props => [
//         pendingTasks,
//         completedTasks,
//         overdueTasks,
//         userId,
//         progress,
//       ];
// }

//general failure message for all fail operation
final class StudyplanCrudOperationFailure extends StudyplanCrudOperationState {
  final String message;

  const StudyplanCrudOperationFailure(this.message);

  @override
  List<Object> get props => [message];
}



// //update task list state
// class UpdateTasksState extends TaskCrudOperationEvent {
//   final List<Task> pendingTasks;
//   final List<Task> completedTasks;
//   final List<Task> overdueTasks;
//   final String userId;
//   final double progress;

//   const UpdateTasksState({
//     required this.pendingTasks,
//     required this.completedTasks,
//     required this.overdueTasks,
//     required this.userId,
//     required this.progress,
//   });

//   @override
//   List<Object> get props => [
//         pendingTasks,
//         completedTasks,
//         overdueTasks,
//         userId,
//         progress,
//       ];
// }