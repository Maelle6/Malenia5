import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/blocs/sleep_bloc/sleep_event.dart';
import 'package:learning_app/blocs/sleep_bloc/sleep_state.dart';
import 'package:learning_app/models/sleep_relaxation_card.dart';
import 'package:learning_app/models/sleep_music_card.dart';
import 'package:learning_app/models/sleep_tip_card.dart';

class SleepBloc extends Bloc<SleepEvent, SleepState> {
  SleepBloc() : super(SleepLoading()) {
    // Registering the event handler
    on<LoadSleepContentEvent>(_onLoadSleepContent);
  }

  Future<void> _onLoadSleepContent(
      LoadSleepContentEvent event, Emitter<SleepState> emit) async {
    emit(SleepLoading()); // Emit loading state
    try {
      // Simulate data fetching
      await Future.delayed(const Duration(seconds: 1));

      // Sample data (replace with real data fetching logic)
      final List<RelaxationCard> relaxationCards = [
        RelaxationCard(
            title: 'Breathing Exercise',
            duration: '4:58 min',
            imageUrl: 'assets/Images/sleepImage1.jpg',
            videoUrl: 'assets/videos/sleepVideo1.mp4',
            description:
                'Struggling to fall asleep? A calming breathing exercise can help relax your mind and body, making it easier to drift off into a peaceful slumber.\n\n'
                'This guided breathing exercise helps you:\n\n'
                '✔ Slow your breathing to induce relaxation.\n\n'
                '✔ Quiet your mind and reduce nighttime anxiety.\n\n'
                '✔ Prepare your body for restful sleep.\n\n'
                'By practicing this breathing technique before bed, you can enhance sleep quality and wake up feeling refreshed.',
            backgroundColor: const Color.fromARGB(255, 80, 37, 73)),
        RelaxationCard(
            title: 'Before You Sleep',
            duration: '9:58 min',
            imageUrl: 'assets/Images/sleepImage2.jpg',
            videoUrl: 'assets/videos/sleepVideo2.mp4',
            description:
                'A racing mind can keep you awake, but calming techniques can help you regain control and ease into restful sleep. This meditation helps quiet the chatter and prepare your mind for deep relaxation.\n\n'
                'This guided meditation helps you:\n\n'
                '✔ Calm overactive thoughts and mental chatter.\n\n'
                '✔ Relieve stress and tension before bed.\n\n'
                '✔ Create a peaceful mindset conducive to sleep.\n\n'
                'By using this technique regularly, you can settle your mind and promote a deeper, more restful sleep.',
            backgroundColor: const Color.fromARGB(255, 155, 35, 129)),
        RelaxationCard(
            title: 'Wind Down Body Scan',
            duration: '10:48 min',
            imageUrl: 'assets/Images/mindImage2.jpg',
            videoUrl: 'assets/videos/sleepVideo3.mp4',
            description:
                'End your day with a soothing body scan meditation. This practice helps you release tension from head to toe, promoting deep relaxation and preparing your body for restful sleep\n\n'
                'This guided body scan helps you:\n\n'
                '✔ Focus on each part of your body to release tension.\n\n'
                '✔ Cultivate mindfulness and relaxation.\n\n'
                '✔ Ease into a peaceful, restorative sleep.\n\n'
                'By incorporating this wind-down body scan, you can effectively relax both your body and mind, setting the stage for a calm and restful night.',
            backgroundColor: const Color.fromARGB(255, 172, 78, 151)),
      ];

      final List<MusicCard> musicCards = [
        MusicCard(
            title: 'Dreamy',
            imageUrl: 'assets/Images/sleepImage4.jpg',
            audioUrl: 'assets/audio/sleepAudio.mp3',
            audioTitle: "Dreamy",
            backgroundColor: const Color.fromARGB(255, 115, 6,
                129)), /*
        MusicCard(
            title: 'Tranquil',
            imageUrl: 'assets/Images/sleepImage5.jpg',
            audioUrl: 'assets/audio/meditationAudio2.mp3',
            audioTitle: "Tranquil",
            backgroundColor: const Color.fromARGB(255, 115, 6, 129)),*/
      ];

      final List<TipCard> tipCards = [
        TipCard(
            tip:
                'Go to sleep at the same time every night to regulate your sleep cycle.'),
        TipCard(tip: 'Keep your room dark, quiet and cool for optimal rest.'),
        TipCard(tip: 'Try deep breathing or meditation to unwind before bed.'),
        TipCard(tip: 'Avoid caffeine or heavy meals close to bedtime.'),
        TipCard(
            tip:
                'Regular physical activity helps you fall asleep faster at night.'),
      ];

      emit(SleepLoaded(
        relaxationCards: relaxationCards,
        musicCards: musicCards,
        tipCards: tipCards,
      ));
    } catch (e) {
      print('Error fetching sleep content: $e'); // Log the error
      emit(SleepError()); // Emit error state
    }
  }
}
