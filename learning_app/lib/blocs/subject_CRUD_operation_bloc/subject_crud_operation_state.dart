part of 'subject_crud_operation_bloc.dart';

abstract class SubjectCrudOperationState extends Equatable {
  const SubjectCrudOperationState();

  @override
  List<Object> get props => [];
}

final class SubjectCrudOperationInitial extends SubjectCrudOperationState {}

final class SubjectCrudOperationLoading extends SubjectCrudOperationState {}

final class SubjectCrudOperationLoaded extends SubjectCrudOperationState {
  final List<Subject> subjects;

  const SubjectCrudOperationLoaded({this.subjects = const []});

  @override
  List<Object> get props => [subjects];
}

final class SubjectCrudOperationFailure extends SubjectCrudOperationState {
  final String message;

  const SubjectCrudOperationFailure(this.message);

  @override
  List<Object> get props => [message];
}
