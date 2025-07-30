import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Tip Card Example')),
        body: const Center(
          child: SingleChildScrollView(
            child: Padding(
              padding:  EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TipCard(title: 'Stay hydrated and take breaks!'),
                   SizedBox(height: 20),
                  TipCard(title: 'Don\'t forget to stretch your legs!'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TipCard extends StatefulWidget {
  final String title;

  const TipCard({
    super.key,
    required this.title,
  });

  @override
  _TipCardState createState() => _TipCardState();
}

class _TipCardState extends State<TipCard> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.fromLTRB(12, 20, 0, 21),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color:const Color.fromARGB(214, 231, 18, 107),
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
              activeColor: const Color.fromARGB(255, 214, 20, 85),
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
              widget.title,
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
