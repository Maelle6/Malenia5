import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:studyplan_repository/studyplan_repository.dart';
part 'studyplan_crud_operation_event.dart';
part 'studyplan_crud_operation_state.dart';

class StudyplanCrudOperationBloc
    extends Bloc<StudyplanCrudOperationEvent, StudyplanCrudOperationState> {
  final StudyplanRepository _studyplanRepository;
  StreamSubscription<List<Studyplan>>? _studyplanStreamSubscription;

  StudyplanCrudOperationBloc({required StudyplanRepository studyplanRepository})
      : _studyplanRepository = studyplanRepository,
        super(StudyplanCrudOperationInitial()) {
    on<FetchStudyplan>((event, emit) async {
      emit(StudyplanCrudOperationLoading());
      await _studyplanStreamSubscription?.cancel();

      await emit.forEach(
        _studyplanRepository.getStudyplanStream(event.userId),
        onData: (List<Studyplan> studyplans) => StudyplanCrudOperationLoaded(
            'Studyplans fetched successfully',
            studyplans: studyplans),
        onError: (error, stackTrace) =>
            StudyplanCrudOperationFailure('Error fetching Studyplan: $error'),
      );
    });

    on<CreateStudyplan>((event, emit) async {
      emit(StudyplanCrudOperationLoading());
      try {
        await _studyplanRepository.createStudyplan(
            event.studyplan, event.userId);
        final studyplans =
            await _studyplanRepository.getStudyplanStream(event.userId).first;
        emit(StudyplanCrudOperationLoaded('Studyplan created successfully',
            studyplans: studyplans));
      } catch (e) {
        emit(StudyplanCrudOperationFailure('Failed to create Studyplan: $e'));
      }
    });

    on<DeleteStudyplan>((event, emit) async {
      emit(StudyplanCrudOperationLoading());
      try {
        await _studyplanRepository.deleteStudyplan(event.studyplanId);
        final studyplans =
            await _studyplanRepository.getStudyplanStream(event.userId).first;
        emit(StudyplanCrudOperationLoaded('Studyplan deleted successfully',
            studyplans: studyplans));
      } catch (e) {
        emit(StudyplanCrudOperationFailure('Failed to delete Studyplan: $e'));
      }
    });

    on<UpdateStudyplan>((event, emit) async {
      emit(StudyplanCrudOperationLoading());
      try {
        await _studyplanRepository.updateStudyplan(event.updatedStudyplan);
        final studyplans = await _studyplanRepository
            .getStudyplanStream(event.updatedStudyplan.userId)
            .first;
        emit(StudyplanCrudOperationLoaded('Studyplan updated successfully',
            studyplans: studyplans));
      } catch (e) {
        emit(StudyplanCrudOperationFailure('Failed to update Studyplan: $e'));
      }
    });
  }

  @override
  Future<void> close() {
    _studyplanStreamSubscription?.cancel();
    return super.close();
  }
}
