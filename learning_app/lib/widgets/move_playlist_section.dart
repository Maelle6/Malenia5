import 'package:flutter/material.dart';
import 'package:learning_app/models/move_playlist_card.dart';

class PlaylistSection extends StatelessWidget {
  const PlaylistSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine the appropriate text color based on the current theme
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 17, 0, 0),
          child: Text(
            'Energizing Playlists',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: textColor, // Dynamic text color based on theme
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 9, 0),
          child: Row(
            children: [
              Expanded(
                child: PlaylistCard(
                  title: 'Upbeat',
                  audioUrl: 'assets/audio/moveAudio.mp3',
                  audioTitle: "Upbeat",
                  backgroundColor: Color(0xFFD200C4),
                  imageUrl: 'assets/Images/moveImage4.png',
                ),
              ),
              SizedBox(width: 12),
              /*
              Expanded(
                child: PlaylistCard(
                  title: 'Spirit',
                  backgroundColor: const Color(0xFFF528B7),
                  audioUrl: 'assets/audio/moveAudio2.mp3',
                  audioTitle: 'Spirit', // Pass the title directly to audioTitle
                  imageUrl: 'assets/Image/moveImage5.png',
                ),
              ),*/
            ],
          ),
        ),
      ],
    );
  }
}
