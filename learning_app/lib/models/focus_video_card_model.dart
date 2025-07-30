import 'package:flutter/material.dart';

class VideoCardModel {
  final String title;
  final String duration;
  final String imageUrl;
  final Color backgroundColor;
  final String videoUrl;
  final String description;

  VideoCardModel({
    required this.title,
    required this.duration,
    required this.imageUrl,
    required this.backgroundColor,
    required this.videoUrl,
    required this.description,
  });
}
