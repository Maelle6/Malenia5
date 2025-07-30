import 'package:flutter/material.dart';
import 'package:learning_app/screens/audio_player.dart'; // Import the AudioPlayerScreen

class MusicCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final Color backgroundColor;
  final String audioUrl; // Add audioUrl as a parameter
  final String audioTitle; // Add audioTitle as a parameter

  const MusicCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.backgroundColor,
    required this.audioUrl, // Include audioUrl in the constructor
    required this.audioTitle, // Include audioTitle in the constructor
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
              audioUrl: audioUrl,
              audioTitle: audioTitle,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4), // Margin added here
        child: Container(
          width: 175,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: backgroundColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .start, // Prevent overflow by starting from left
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      10, 0, 6, 0), // Padding for the text
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      const SizedBox(height: 10), // Reduced space
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
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imageUrl,
                  width: 162,
                  height: 114,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
