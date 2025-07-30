import 'package:flutter/material.dart';

class TipCard extends StatefulWidget {
  final String tip;

  const TipCard({
    super.key,
    required this.tip,
  });

  @override
  _TipCardState createState() => _TipCardState();
}

class _TipCardState extends State<TipCard> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: const EdgeInsets.fromLTRB(12, 20, 0, 21),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: const Color(0xD963169E),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value ?? false;
                });
              },
              activeColor: const Color.fromARGB(255, 130, 69, 141),
              checkColor: Colors.white,
              shape: const CircleBorder(),
              side: const BorderSide(
                color: Colors.white,
                width: 2.0,
              ),
            ),
          ),
          const SizedBox(width: 4), // Space between the checkbox and text
          Expanded(
            child: Text(
              widget.tip,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
