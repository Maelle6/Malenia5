import 'package:flutter/material.dart';

class CardCarousel extends StatelessWidget {
  final String cardImg;
  final Color cardColor;
  final String text;
  final double textSize;
  final double imgSize;
  final Function onTap;

  const CardCarousel(
      {required this.cardImg,
      required this.cardColor,
      required this.text,
      required this.textSize,
      required this.imgSize,
      required this.onTap,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: InkWell(
        onTap: () => onTap(),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          color: cardColor,
          margin: EdgeInsets.zero, // Remove default margin
          child: Padding(
            padding: EdgeInsets.zero, // No padding around the card content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image at the top
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.asset(
                    cardImg, // Replace with your image path
                    height: imgSize, // Adjust as needed
                    width: imgSize,
                    fit: BoxFit.contain,
                  ),
                ),

                // Text directly below the image, without extra space
                Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: textSize,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white // Black mode color
                        : Colors.black,
                    // height: 0.1, // Reduce line height to remove extra space
                  ),
                  textAlign: TextAlign.center, // Align text if necessary
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
