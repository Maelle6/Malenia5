// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class QuestionTile extends StatelessWidget {
  final String message;
  final String time;

  const QuestionTile({
    required this.message,
    required this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 42, left: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildMessageBubble(context, message),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 5, 12, 0),
                child: Text(
                  time,
                  style: TextStyle(
                      color: Color.fromRGBO(176, 172, 172, 1),
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, String message) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(0),
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25)),
          color: Color.fromRGBO(142, 89, 255, 1)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Text(
          message,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: Colors.white,
          ),
          softWrap: true,
        ),
      ),
    );
  }
}
