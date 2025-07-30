abstract class ChatState {}

class ChatInitialState extends ChatState {}

class LoadingState extends ChatState {}

class ChatMessageSentState extends ChatState {
  final String message;

  ChatMessageSentState(this.message);
}

class MessagesUpdatedState extends ChatState {
  final List<Map<String, String>> messages;

  MessagesUpdatedState(this.messages);
}
