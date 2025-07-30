// ignore_for_file: prefer_const_constructors, use_super_parameters

import 'package:flutter/material.dart';

class InitialTile extends StatelessWidget {

  final AssetImage avatarImage;
  final String message;
  final String time;

  const InitialTile({
   
    required this.avatarImage,
    required this.message,
    required this.time,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              _buildAvatar(avatarImage),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageBubble(message),
                 
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(12, 5, 0, 0),
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
        ],
      ),
    );
  }

  Widget _buildAvatar(AssetImage image) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundImage: image,
        radius: 17,
      ),
    );
  }

  Widget _buildMessageBubble(String message) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.all(10),
          constraints: BoxConstraints(
            maxWidth:
                constraints.maxWidth * 0.75, // Dynamically calculate width
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)),
              color: Theme.of(context).brightness ==
                      Brightness.light //colour of message bubble
                  ? Color.fromRGBO(236, 236, 236, 1)
                  : Color(0xFF292C31) //dark mode
             
              ),
          child: Text(
            message,
            style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white //dark mode
                ),
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        );
      },
    );
  }
}
