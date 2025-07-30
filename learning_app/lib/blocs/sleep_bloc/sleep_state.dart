import 'package:learning_app/models/sleep_relaxation_card.dart';
import 'package:learning_app/models/sleep_music_card.dart';
import 'package:learning_app/models/sleep_tip_card.dart';

abstract class SleepState {}

class SleepLoading extends SleepState {}

class SleepError extends SleepState {}

class SleepLoaded extends SleepState {
  final List<RelaxationCard> relaxationCards;
  final List<MusicCard> musicCards;
  final List<TipCard> tipCards;

  SleepLoaded({
    required this.relaxationCards,
    required this.musicCards,
    required this.tipCards,
  });
}
