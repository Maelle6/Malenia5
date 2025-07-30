import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_app/blocs/move_bloc/move_event.dart';
import 'package:learning_app/blocs/move_bloc/move_state.dart';

class MoveScreenBloc extends Bloc<MoveScreenEvent, MoveScreenState> {
  MoveScreenBloc() : super(MoveScreenInitial()) {
    // Registering event handler for each event
    on<LoadMoveScreenEvent>(_onLoadMoveScreen);
    on<LoadStretchingSectionEvent>(_onLoadStretchingSection);
    on<LoadPlaylistSectionEvent>(_onLoadPlaylistSection);
    on<LoadFocusTipsSectionEvent>(_onLoadFocusTipsSection);
  }

  // Event handler for LoadMoveScreenEvent
  Future<void> _onLoadMoveScreen(
      LoadMoveScreenEvent event, Emitter<MoveScreenState> emit) async {
    emit(MoveScreenInitial());
  }

  // Event handler for StretchingSection
  Future<void> _onLoadStretchingSection(
      LoadStretchingSectionEvent event, Emitter<MoveScreenState> emit) async {
    emit(StretchingSectionLoaded());
  }

  // Event handler for PlaylistSection
  Future<void> _onLoadPlaylistSection(
      LoadPlaylistSectionEvent event, Emitter<MoveScreenState> emit) async {
    emit(PlaylistSectionLoaded());
  }

  // Event handler for FocusTipsSection
  Future<void> _onLoadFocusTipsSection(
      LoadFocusTipsSectionEvent event, Emitter<MoveScreenState> emit) async {
    emit(FocusTipsSectionLoaded());
  }
}
