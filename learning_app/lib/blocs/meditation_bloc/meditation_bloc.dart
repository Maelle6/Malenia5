import 'package:bloc/bloc.dart';
import 'meditation_event.dart';
import 'meditation_state.dart';

class MeditationBloc extends Bloc<MeditationEvent, MeditationState> {
  MeditationBloc() : super(MeditationInitialState()) {
    on<LoadMeditationDataEvent>((event, emit) async {
      emit(MeditationLoadingState());
      try {
        // Dummy data for now
        List<String> tips = [
          'Begin with 3-5 minutes and gradually increase as you feel comfortable.',
          'Bring your attention back to your breath whenver your mind wanders.',
          'Choose a quiet, comfortable spot to meditate without distractions.',
          'Gently refocus when your mind drifts - avoid self-judgement.',
          'Practice daily, even for just a few minutes, to build a habit'
        ];
        List<String> music = ['White Noise', 'Rain Storm'];
        List<String> meditations = ['Morning Meditation', 'Evening Relaxation'];

        emit(MeditationLoadedState(
          meditationTips: tips,
          relaxingMusic: music,
          guidedMeditations: meditations,
        ));
      } catch (e) {
        emit(MeditationErrorState(message: 'Error loading data.'));
      }
    });
  }
}
