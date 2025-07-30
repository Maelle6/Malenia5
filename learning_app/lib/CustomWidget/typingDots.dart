// import 'dart:ui';

import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

class typingDots extends StatelessWidget {
  final Color color;

  const typingDots({super.key, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedDot(color: color),
        AnimatedDot(color: color),
        AnimatedDot(color: color),
      ],
    );
  }
}

class AnimatedDot extends StatefulWidget {
  final Color color;

  const AnimatedDot({super.key, this.color = Colors.grey});

  @override
  _AnimatedDotState createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<AnimatedDot>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
