import 'package:flutter/material.dart';

class MusicCard {
  final String title;
  final String imageUrl;
  final Color backgroundColor;
  final String audioUrl;
  final String audioTitle;

  MusicCard({
    required this.title,
    required this.imageUrl,
    required this.backgroundColor,
    required this.audioUrl,
    required this.audioTitle,
  });
}
