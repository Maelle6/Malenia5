import 'package:flutter/material.dart';
import 'package:learning_app/models/focus_music_card_model.dart';
import 'package:learning_app/screens/audio_player.dart';

class MusicCardWidget extends StatelessWidget {
  final MusicCardModel musicCard;

  const MusicCardWidget({super.key, required this.musicCard});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (musicCard.imageUrl.isNotEmpty)
        ? musicCard.imageUrl
        : 'assets/Images/meditation2.png';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioPlayerScreen(
              audioUrl: 'assets/audio/focusAudio.mp3',
              audioTitle: musicCard.title,
              imageUrl: 'assets/Images/focusImage5.jpg',
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: musicCard.backgroundColor,
        ),
        width: 500,
        child: Row(
          children: [
            // Expanded text section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    musicCard.title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Music',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(), // Pushes the image completely to the right
            // Image section
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imageUrl,
                width: 159,
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
