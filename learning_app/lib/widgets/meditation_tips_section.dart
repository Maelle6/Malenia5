import 'package:flutter/material.dart';
import 'package:learning_app/widgets/meditation_tip_card.dart';

class MeditationTipSection extends StatelessWidget {
  final List<String> tips;

  const MeditationTipSection({super.key, required this.tips});

  @override
  Widget build(BuildContext context) {
    // Determine the appropriate title color based on the current theme
    final titleColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 30, 0, 21),
          child: Text(
            'Meditation Tips',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
              color: titleColor, // Dynamic title color based on theme
            ),
          ),
        ),
        ...tips.map(
          (tip) => MeditationTipCard(tip: tip),
        ),
      ],
    );
  }
}
