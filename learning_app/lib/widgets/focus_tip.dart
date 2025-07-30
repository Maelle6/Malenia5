import 'package:flutter/material.dart';
import 'package:learning_app/models/focus_tip_model.dart';

class FocusTipCardWidget extends StatelessWidget {
  final FocusTipCardModel focusTipCard;
  final ValueChanged<bool?> onChanged;

  const FocusTipCardWidget({
    required this.focusTipCard,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
      padding: const EdgeInsets.fromLTRB(12, 20, 0, 21),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: const Color.fromRGBO(205, 81, 44, 0.85),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: focusTipCard.isChecked,
              onChanged: onChanged,
              activeColor: const Color.fromARGB(255, 175, 75, 28),
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
              focusTipCard.tip,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
