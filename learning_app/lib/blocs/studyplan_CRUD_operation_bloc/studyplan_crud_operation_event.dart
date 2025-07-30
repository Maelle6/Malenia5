part of 'studyplan_crud_operation_bloc.dart';

abstract class StudyplanCrudOperationEvent extends Equatable {
  const StudyplanCrudOperationEvent();

  @override
  List<Object> get props => [];
}

class CreateStudyplan extends StudyplanCrudOperationEvent {
  final Studyplan studyplan;
  final String userId;

  const CreateStudyplan(this.studyplan, this.userId);

  @override
  List<Object> get props => [studyplan, userId];
}

class DeleteStudyplan extends StudyplanCrudOperationEvent {
  final String userId;
  final String studyplanId;


  const DeleteStudyplan(this.studyplanId, this.userId);

  @override
  List<Object> get props => [studyplanId, userId];
}

// class UpdateTaskStatus extends TaskCrudOperationEvent {
//   final String userId;
//   final String taskId;
//   final bool isDone;
//   final int notificationId;

//   const UpdateTaskStatus(
//       this.taskId, this.isDone, this.userId, this.notificationId);

//   @override
//   List<Object> get props => [
//         taskId,
//         isDone,
//         userId,
//         notificationId,
//       ];
// }

class UpdateStudyplan extends StudyplanCrudOperationEvent {
  final Studyplan updatedStudyplan;
  final String userId;

  const UpdateStudyplan(this.updatedStudyplan, this.userId);

  @override
  List<Object> get props => [updatedStudyplan, userId];
}

class FetchStudyplan extends StudyplanCrudOperationEvent {
  final String userId;

  const FetchStudyplan({required this.userId});

  @override
  List<Object> get props => [userId];
}
