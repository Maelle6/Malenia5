import 'package:learning_app/models/focus_music_card_model.dart';
import 'package:learning_app/models/focus_video_card_model.dart';
import 'package:learning_app/models/focus_tip_model.dart';

abstract class FocusPageState {}

class FocusPageLoading extends FocusPageState {}

class FocusPageLoaded extends FocusPageState {
  final List<VideoCardModel> videoCards;
  final List<MusicCardModel> musicCards;
  final List<FocusTipCardModel> focusTips;

  FocusPageLoaded({
    required this.videoCards,
    required this.musicCards,
    required this.focusTips,
  });
}

class FocusPageError extends FocusPageState {}
