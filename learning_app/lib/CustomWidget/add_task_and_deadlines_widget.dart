import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddTaskAndDeadlineWidget extends StatelessWidget {
  final double textSize;
  final String title;
  final String trailingIconPath;
  final double widthImg;
  final double heightImg;
  final String textStyle;
  final String routeName;
  final Color color;
  final Color iconColor;
  final Color textColor;

  const AddTaskAndDeadlineWidget({
    super.key,
    required this.textSize,
    required this.title,
    required this.trailingIconPath,
    required this.widthImg,
    required this.heightImg,
    required this.textStyle, 
    required this.routeName,
    required this.color,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        child: ListTile(
          minLeadingWidth: 27,
          horizontalTitleGap: 20,
          contentPadding:
              const EdgeInsets.only(top: 10, bottom: 10, left: 23, right: 23),
          title: Text(
            title,
            textWidthBasis: TextWidthBasis.longestLine,
            softWrap: true,
            maxLines: 2, // Allows a maximum of 2 lines
            overflow: TextOverflow.ellipsis, // Adds ellipsis if text overflows
            style: TextStyle(
              fontSize: textSize,
              fontFamily: textStyle,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          // Custom trailing icon (SVG in this case)
          trailing: SvgPicture.asset(
            trailingIconPath, // Path to your custom SVG icon
            width: widthImg,
            height: heightImg,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
