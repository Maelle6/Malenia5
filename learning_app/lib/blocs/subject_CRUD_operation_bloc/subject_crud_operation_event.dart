part of 'subject_crud_operation_bloc.dart';

abstract class SubjectCrudOperationEvent extends Equatable {
  const SubjectCrudOperationEvent();

  @override
  List<Object> get props => [];
}

class CreateSubject extends SubjectCrudOperationEvent {
  final Subject subject;
  final String userId;

  const CreateSubject(this.subject, this.userId);

  @override
  List<Object> get props => [subject, userId];
}

class DeleteSubject extends SubjectCrudOperationEvent {
  final String userId;
  final String subjectId;

  const DeleteSubject(this.subjectId, this.userId);

  @override
  List<Object> get props => [subjectId, userId];
}

class UpdateSubject extends SubjectCrudOperationEvent {
  final Subject updatedSubject;
  final String userId;

  const UpdateSubject(this.updatedSubject, this.userId);

  @override
  List<Object> get props => [updatedSubject, userId];
}

class FetchSubjects extends SubjectCrudOperationEvent {
  final String userId;

  const FetchSubjects({required this.userId});

  @override
  List<Object> get props => [userId];
}
