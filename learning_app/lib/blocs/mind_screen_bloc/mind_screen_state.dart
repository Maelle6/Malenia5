abstract class MindScreenState {}

class MindInitial extends MindScreenState {}

class MindLoading extends MindScreenState {}

class MindLoaded extends MindScreenState {
  final List<String> data; // Example data
  MindLoaded(this.data);
}

class MindError extends MindScreenState {
  final String message;
  MindError(this.message);
}
