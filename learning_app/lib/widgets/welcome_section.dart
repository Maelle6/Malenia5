import 'package:flutter/material.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to the Mind Section!',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'Tools to manage stress, reduce anxiety and cultivate calm.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          ),
          SizedBox(height: 22),
          // Add action buttons like Meditate, Focus here
        ],
      ),
    );
  }
}
