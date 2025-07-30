import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/blocs/focus_bloc/focus_state.dart';
import 'package:learning_app/blocs/focus_bloc/focus_event.dart';
import 'package:learning_app/models/focus_music_card_model.dart';
import 'package:learning_app/models/focus_video_card_model.dart';
import 'package:learning_app/models/focus_tip_model.dart';

// BLoC
class FocusPageBloc extends Bloc<FocusPageEvent, FocusPageState> {
  FocusPageBloc() : super(FocusPageLoading()) {
    on<LoadFocusPageEvent>(_onLoadFocusPage);
  }

  Future<void> _onLoadFocusPage(
    LoadFocusPageEvent event,
    Emitter<FocusPageState> emit,
  ) async {
    emit(FocusPageLoading());

    try {
      // Simulate loading data
      await Future.delayed(const Duration(seconds: 2));

      final videoCards = [
        VideoCardModel(
            title: 'Improve Your Focus',
            duration: '5:05',
            videoUrl: 'assets/videos/focusVideo1.mp4',
            imageUrl: 'assets/Images/focusImage1.jpg',
            description:
                'In a world full of distractions, staying focused can be challenging. Meditation helps train your mind to be more present, improving concentration and mental clarity.\n\n'
                'This video helps you:\n\n'
                '✔ Enhance focus and productivity.\n\n'
                '✔ Reduce mental clutter and distractions.\n\n'
                '✔ Strengthen your ability to stay present in tasks.\n\n'
                'By practicing mindfulness, you can develop a sharper, more focused mind, making it easier to accomplish your goals with clarity and purpose.',
            backgroundColor: const Color.fromARGB(255, 255, 65, 7)),
        VideoCardModel(
            title: 'Improve Brain Power',
            duration: '10:45',
            videoUrl: 'assets/videos/focusVideo2.mp4',
            imageUrl: 'assets/Images/focusImage2.jpg',
            description:
                'Just like the body, the brain thrives with the right training. Meditation enhances cognitive function, improves memory, and boosts mental clarity, helping you think sharper and perform better.\n\n'
                'This video helps you:\n\n'
                '✔ Strengthen focus and mental agility.\n\n'
                '✔ Enhance memory and information retention.\n\n'
                '✔ Reduce stress for clearer thinking.\n\n'
                'By incorporating mindfulness into your routine, you can unlock your brain’s full potential and stay mentally sharp throughout the day.',
            backgroundColor: const Color.fromARGB(255, 201, 76, 45)),
        VideoCardModel(
            title: 'Mastering The Flow State',
            duration: '11:15',
            videoUrl: 'assets/videos/focusVideo3.mp4',
            description:
                'Want to enter the flow state faster?  This video helps you seamlessly tap into deep focus, eliminating distractions and enhancing your concentration in just a few minutes.\n\n'
                'This video helps you:\n\n'
                '✔ Teaches you about the flow state\n\n'
                '✔ Explains the flow triggers\n\n'
                '✔ Teaches you about the 4 pillars of flow\n\n'
                'Use this quick flow-state hack whenever you need to immerse yourself in your work with total clarity and ease.',
            imageUrl: 'assets/Images/focusImage3.jpg',
            backgroundColor: const Color.fromARGB(255, 201, 76, 45)),
      ];

      final musicCards = [
        /*
        MusicCardModel(
            title: 'Deep Focus',
            imageUrl: 'assets/Images/focusImage4.jpg',
            audioUrl: 'assets/audio/focusAudio.mp3',
            backgroundColor: Colors.orange),*/

        MusicCardModel(
            title: 'Intense Study',
            imageUrl: 'assets/Images/focusImage5.jpg',
            audioUrl: 'assets/audio/focusAudio.mp3',
            backgroundColor: Colors.orange),
      ];

      final focusTips = [
        FocusTipCardModel(
            tip: 'Tackle one thing at a time to avoid feeling overwhelmed.'),
        FocusTipCardModel(
            tip: 'Work for 25 minutes, then take a 5-minute break.'),
        FocusTipCardModel(
            tip:
                'Turn off notifications and create a quiet workspace to improve concentration.'),
        FocusTipCardModel(
            tip:
                'Drink water and take short breaks to maintain energy and mental clarity.'),
        FocusTipCardModel(
            tip:
                'Take a few minutes to breathe and center yourself before diving into tasks'),
      ];

      emit(FocusPageLoaded(
        videoCards: videoCards,
        musicCards: musicCards,
        focusTips: focusTips,
      ));
    } catch (_) {
      emit(FocusPageError());
    }
  }
}
