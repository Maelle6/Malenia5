// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:learning_app/Constants/constant.dart';
import 'package:learning_app/CustomWidget/typingDots.dart';
import 'package:learning_app/blocs/chatbot_bloc/chatbot_bloc.dart';
import 'package:learning_app/blocs/chatbot_bloc/chatbot_event.dart';
import 'package:learning_app/blocs/chatbot_bloc/chatbot_state.dart';
import 'package:learning_app/screens/chatbot/components/initial.dart';
import 'package:learning_app/screens/chatbot/components/questionTile.dart';
import 'package:learning_app/screens/chatbot/components/responseTile.dart';

String getCurrentTime() {
  return DateFormat('HH:mm').format(DateTime.now());
}

class ChatbotScreen extends StatefulWidget {
  final Function(int) onNavigate;
  final bool showAvatar;

  const ChatbotScreen({
    super.key,
    required this.onNavigate,
    this.showAvatar = true,
  });
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            backArrowSvg,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color!,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => widget.onNavigate(0),
        ),
        title: const Text('Chatbot'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Color(0xFF242424)
                                    : Colors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
                        // ignore: duplicate_ignore
                        // ignore: prefer_const_constructors
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Color(0xFF242424)
                                  : Colors.grey,
                          fontSize: 12,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Color(0xFF242424)
                                    : Colors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 40,
              left: 0,
              right: 0,
              bottom: 90,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    final lastUserMessage =
                        context.read<ChatBloc>().lastUserMessage;
                    if (state is LoadingState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display the user's last message
                          QuestionTile(
                            message: lastUserMessage,
                            time: getCurrentTime(),
                          ),
                          // Show typing indicator
                          Padding(
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.12,
                              top: 8,
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  'Typing...',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                SizedBox(width: 8),
                                typingDots(
                                    color: Color.fromRGBO(142, 89, 255, 1)),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    if (state is MessagesUpdatedState) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      });
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final messageData = state.messages[index];
                          final sender = messageData['sender']!;
                          final message = messageData['message']!;
                          if (sender == 'user') {
                            // Display the user’s message
                            return QuestionTile(
                              message: message,
                              time: getCurrentTime(),
                            );
                          } else {
                            // Display the AI’s response
                            return ResponseTile(
                              avatarImage: AssetImage('assets/icons/robot.png'),
                              message: message,
                              time: getCurrentTime(),
                            );
                          }
                        },
                      );
                    }
                    return ListView(
                      controller: _scrollController,
                      children: [
                        InitialTile(
                          // ignore: duplicate_ignore
                          // ignore: prefer_const_constructors
                          avatarImage: AssetImage('assets/icons/robot.png'),
                          message: "Hello this is your AI Assistant!",
                          time: getCurrentTime(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 16, 2, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white, // Text color based on theme
                          ),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Color.fromARGB(255, 223, 223, 223)
                                  : const Color.fromARGB(255, 41, 44,
                                      49), //background of textfield
                              hintText: 'Write a message',
                              hintStyle: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.white),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12),
                              border: InputBorder.none,
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(12))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 1),
                    IconButton(
                      icon: CircleAvatar(
                          backgroundImage: Theme.of(context).brightness ==
                                  Brightness.light
                              ? AssetImage('assets/icons/send.jpg')
                              : AssetImage('assets/icons/send_darkMode.jpg')),
                      onPressed: () {
                        String message = _controller.text.trim();
                        if (message.isNotEmpty) {}
                        // Scroll to the bottom when a new message is sent
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );

                        // Dismiss the keyboard by unfocusing the text field
                        FocusScope.of(context).unfocus();
                        context.read<ChatBloc>().add(SendMessageEvent(message));
                        _controller.clear(); // Clear the input field
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
