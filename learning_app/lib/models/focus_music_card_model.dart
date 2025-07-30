import 'package:flutter/material.dart';

class MusicCardModel {
  final String title;
  final String imageUrl;
  final Color backgroundColor;
  final String audioUrl;

  MusicCardModel({
    required this.title,
    required this.imageUrl,
    required this.backgroundColor,
    required this.audioUrl,
  });
}
