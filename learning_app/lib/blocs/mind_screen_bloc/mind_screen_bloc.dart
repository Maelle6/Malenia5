import 'package:bloc/bloc.dart';
import 'mind_screen_event.dart';
import 'mind_screen_state.dart';
import 'package:learning_app/repositories/mind_repository.dart';

class MindScreenBloc extends Bloc<MindScreenEvent, MindScreenState> {
  final MindRepository repository;

  MindScreenBloc(this.repository) : super(MindInitial()) {
    on<LoadMindData>((event, emit) async {
      emit(MindLoading());
      try {
        final data = await repository.fetchMindData();
        emit(MindLoaded(data));
      } catch (e) {
        emit(MindError("Failed to load data"));
      }
    });
  }
}
