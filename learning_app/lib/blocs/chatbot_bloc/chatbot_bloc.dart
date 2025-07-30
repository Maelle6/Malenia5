// lib/bloc/chat_bloc.dart
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:learning_app/consts.dart';
import 'chatbot_event.dart';
import 'chatbot_state.dart';

class ChatBloc extends Bloc<ChatbotEvent, ChatState> {
  List<Map<String, String>> messages = [];
  String lastUserMessage = '';
  ChatBloc() : super(ChatInitialState()) {
    on<SendMessageEvent>((event, emit) async {
      lastUserMessage = event.message;
      messages.add({
        'message': event.message,
        'time': DateFormat('HH:mm').format(DateTime.now()),
        'sender': 'user',
      });

      emit(LoadingState());

      emit(MessagesUpdatedState(messages));

      emit(LoadingState());

      try {
        final aiResponse = await getResponseFromAI(messages);

        messages.add({
          'message': aiResponse,
          'time': DateFormat('HH:mm').format(DateTime.now()),
          'sender': 'ai',
        });

        emit(MessagesUpdatedState(messages));
      } catch (e) {
        // Handle errors if AI request fails
        print("Error fetching AI response: $e");

        // Add a fallback AI message
        messages.add({
          'message':
              'Sorry, I couldn’t get a response. Please try again later.',
          'time': DateFormat('HH:mm').format(DateTime.now()),
          'sender': 'ai',
        });

        emit(MessagesUpdatedState(messages));
      }
    });
  }

  Future<String> getResponseFromAI(List<Map<String, String>> messages) async {
    final openAI = OpenAI.instance.build(
      token: OPENAI_API_KEY,
      baseOption: HttpSetup(
        receiveTimeout: const Duration(
          seconds: 30,
        ),
      ),
      enableLog: true,
    );

    try {
      // Create the conversation context from the messages list
      List<Map<String, String>> conversationHistory = [];
      for (var msg in messages) {
        conversationHistory.add({
          'role': msg['sender'] == 'user' ? 'user' : 'assistant',
          'content': msg['message'] ?? '',
        });
      }
      // Get response using the SDK's completion method
      final request = ChatCompleteText(
        model: Gpt4oMiniChatModel(),
        messages: conversationHistory,
        maxToken: 600,
      );

      final response = await openAI.onChatCompletion(request: request);

      // Log the entire response
      print("API Response: $response");

      if (response?.choices.isNotEmpty ?? false) {
        final aiResponse = response?.choices.first.message?.content.trim() ??
            'No valid text found';
        return aiResponse;
      } else {
        print("Response has no valid choices: $response");
        throw Exception("No valid response from OpenAI.");
      }
    } catch (e) {
      print("Error fetching AI response: $e");
      throw Exception("Failed to fetch AI response: $e");
    }
  }
}
