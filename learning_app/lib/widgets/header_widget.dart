import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('9:41',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  Image.asset('assets/signal.png', width: 18),
                  const SizedBox(width: 5),
                  Image.asset('assets/wifi.png', width: 15),
                  const SizedBox(width: 5),
                  Image.asset('assets/battery.png', width: 27),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/back.png', width: 32),
              const Text(
                'Mind',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              Image.asset('assets/menu.png', width: 32),
            ],
          ),
        ],
      ),
    );
  }
}
