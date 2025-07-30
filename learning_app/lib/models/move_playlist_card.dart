import 'package:flutter/material.dart';
import 'package:learning_app/screens/audio_player.dart'; // Import the AudioPlayerScreen

class PlaylistCard extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final String imageUrl;
  final String audioUrl;
  final String audioTitle;

  const PlaylistCard({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.imageUrl,
    required this.audioUrl,
    required this.audioTitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to AudioPlayerScreen when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioPlayerScreen(
              audioUrl: audioUrl, // Provide audio URL to play
              audioTitle: audioTitle,
              imageUrl: imageUrl, // Pass the audio title
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: backgroundColor,
        ),
        child: Row(
          children: [
            // The Column now takes only the left side
            Padding(
              padding: const EdgeInsets.only(
                  left: 8), // Add some padding on the left side if needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 7),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 58),
                  const Text(
                    'Music',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 7),
                ],
              ),
            ),
            // Spacer pushes the image to the far right
            const Spacer(),
            // The image will now align to the right without extra padding
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imageUrl,
                width: 159,
                height: 126,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
