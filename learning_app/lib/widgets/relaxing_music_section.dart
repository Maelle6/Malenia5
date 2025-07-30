import 'package:flutter/material.dart';
import 'package:learning_app/screens/audio_player.dart';

class RelaxingMusicSection extends StatelessWidget {
  const RelaxingMusicSection({super.key});

  @override
  Widget build(BuildContext context) {
    final titleColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relaxing Music',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            color: titleColor,
          ),
        ),
        const Row(
          children: [
            Flexible(
              child: MusicCard(
                title: 'White noise',
                audioUrl: 'assets/audio/meditationAudio.mp3',
                imagePath: 'assets/Images/meditationImage3.jpg',
                backgroundColor:  Color.fromRGBO(34, 36, 147, 0.85),
              ),
            ),
            /*
            const SizedBox(width: 16),
            Flexible(
              child: MusicCard(
                title: 'Rain\nStorm',
                audioUrl: 'assets/audio/meditationAudio1.mp3',
                imagePath: 'assets/Images/meditationImage4.jpg',
                backgroundColor: const Color.fromRGBO(80, 82, 208, 0.85),
              ),
            ),*/
          ],
        ),
      ],
    );
  }
}

class MusicCard extends StatelessWidget {
  final String title;
  final String audioUrl;
  final String imagePath;
  final Color backgroundColor;

  const MusicCard({
    required this.title,
    required this.audioUrl,
    required this.imagePath,
    required this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the AudioPlayerScreen when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioPlayerScreen(
              audioUrl: audioUrl,
              audioTitle: title,
              imageUrl: imagePath,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.5),
          color: backgroundColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Music',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(7.5),
              child: Image.asset(
                imagePath,
                width: 168,
                height: 114,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
