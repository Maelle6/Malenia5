import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:subject_repository/subject_repository.dart';

part 'subject_crud_operation_event.dart';
part 'subject_crud_operation_state.dart';

class SubjectCrudOperationBloc
    extends Bloc<SubjectCrudOperationEvent, SubjectCrudOperationState> {
  final SubjectRepository _subjectRepository;
  StreamSubscription<List<Subject>>? _subjectStreamSubscription;

  SubjectCrudOperationBloc({required SubjectRepository subjectRepository})
      : _subjectRepository = subjectRepository,
        super(SubjectCrudOperationInitial()) {
    on<FetchSubjects>(_onFetchSubjects);
    on<CreateSubject>(_onCreateSubject);
    on<DeleteSubject>(_onDeleteSubject);
    on<UpdateSubject>(_onUpdateSubject);
    // Add these new event handlers
    on<FetchSubjectsSuccess>(_onFetchSubjectsSuccess);
    on<FetchSubjectsFailure>(_onFetchSubjectsFailure);
  }

  void _onFetchSubjects(
      FetchSubjects event, Emitter<SubjectCrudOperationState> emit) {
    emit(SubjectCrudOperationLoading());
    // Cancel existing subscription if any
    _subjectStreamSubscription?.cancel();

    // Start a new stream subscription
    _subjectStreamSubscription =
        _subjectRepository.getSubjectStream(event.userId).listen(
      (subjects) {
        add(FetchSubjectsSuccess(subjects));
      },
      onError: (error) {
        add(FetchSubjectsFailure(error.toString()));
      },
    );
  }

  void _onFetchSubjectsSuccess(
      FetchSubjectsSuccess event, Emitter<SubjectCrudOperationState> emit) {
    emit(SubjectCrudOperationLoaded(subjects: event.subjects));
  }

  void _onFetchSubjectsFailure(
      FetchSubjectsFailure event, Emitter<SubjectCrudOperationState> emit) {
    emit(SubjectCrudOperationFailure(event.error));
  }

  void _onCreateSubject(
      CreateSubject event, Emitter<SubjectCrudOperationState> emit) async {
    emit(SubjectCrudOperationLoading());
    try {
      await _subjectRepository.createSubject(event.subject, event.userId);
    } catch (e) {
      emit(SubjectCrudOperationFailure('Failed to create subject: $e'));
    }
  }

  void _onDeleteSubject(
      DeleteSubject event, Emitter<SubjectCrudOperationState> emit) async {
    emit(SubjectCrudOperationLoading());
    try {
      await _subjectRepository.deleteSubject(event.subjectId);
    } catch (e) {
      emit(SubjectCrudOperationFailure('Failed to delete subject: $e'));
    }
  }

  void _onUpdateSubject(
      UpdateSubject event, Emitter<SubjectCrudOperationState> emit) async {
    emit(SubjectCrudOperationLoading());
    try {
      await _subjectRepository.updateSubject(event.updatedSubject);
    } catch (e) {
      emit(SubjectCrudOperationFailure('Failed to update subject: $e'));
    }
  }

  @override
  Future<void> close() {
    _subjectStreamSubscription?.cancel();
    return super.close();
  }
}

// Add these to the event file
class FetchSubjectsSuccess extends SubjectCrudOperationEvent {
  final List<Subject> subjects;

  const FetchSubjectsSuccess(this.subjects);

  @override
  List<Object> get props => [subjects];
}

class FetchSubjectsFailure extends SubjectCrudOperationEvent {
  final String error;

  const FetchSubjectsFailure(this.error);

  @override
  List<Object> get props => [error];
}
