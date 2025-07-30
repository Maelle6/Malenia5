import 'package:flutter/material.dart';

class CardCarouselSpecial extends StatelessWidget {
  final String cardImg;
  final String text;
  final double textSize;
  final double imgSize;

  final List<Color> gradientColors;
  final String value; // New: Dynamic value (e.g., "5h 30m")

  const CardCarouselSpecial({
    required this.cardImg,
    required this.gradientColors,
    required this.text,
    required this.textSize,
    required this.imgSize,
    required this.value, // Accepts dynamic value
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.last.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white.withOpacity(0.1), // Glossy effect
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      cardImg,
                      height: imgSize,
                      width: imgSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Study Hours Text
                  Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: textSize,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Dynamic Hours Value
                  Text(
                    value, // Display live value
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: textSize + 2,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
