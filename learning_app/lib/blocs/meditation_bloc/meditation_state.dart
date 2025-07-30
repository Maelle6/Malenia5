abstract class MeditationState {}

class MeditationInitialState extends MeditationState {}

class MeditationLoadingState extends MeditationState {}

class MeditationLoadedState extends MeditationState {
  final List<String> meditationTips;
  final List<String> relaxingMusic;
  final List<String> guidedMeditations;

  MeditationLoadedState({
    required this.meditationTips,
    required this.relaxingMusic,
    required this.guidedMeditations,
  });
}

class MeditationErrorState extends MeditationState {
  final String message;

  MeditationErrorState({required this.message});
}
