import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 29),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/home.png', width: 24),
          Image.asset('assets/plan.png', width: 24),
          Image.asset('assets/mind.png', width: 24),
          Image.asset('assets/chatbot.png', width: 24),
          Image.asset('assets/stats.png', width: 24),
        ],
      ),
    );
  }
}
