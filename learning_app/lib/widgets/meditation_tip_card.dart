import 'package:flutter/material.dart';

class MeditationTipCard extends StatefulWidget {
  final String tip;

  const MeditationTipCard({
    super.key,
    required this.tip,
  });

  @override
  _MeditationTipCardState createState() => _MeditationTipCardState();
}

class _MeditationTipCardState extends State<MeditationTipCard> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: const Color.fromRGBO(80, 82, 208, 0.85),
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
              activeColor:const Color.fromARGB(80, 113, 66, 243),
              checkColor: Colors.white,
              shape: const CircleBorder(),
              side: const BorderSide(
                color: Colors.white,
                width: 2.0,
              ),
            ),
          ),
          const SizedBox(width: 4),
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
