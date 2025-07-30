import 'package:equatable/equatable.dart';
import '../../deadline_repository.dart';

class Deadline extends Equatable {
  final String userId;
  final String deadlineId;
  final String title;
  final String description;
  final bool isDone;
  final DateTime dueDate;
  final DateTime createdAt;
  final int notificationId;

  const Deadline({
    required this.userId,
    required this.deadlineId,
    required this.title,
    required this.description,
    required this.isDone,
    required this.dueDate,
    required this.createdAt,
    required this.notificationId,
  });
  static final empty = Deadline(
    userId: '',
    deadlineId: '',
    title: '',
    description: '',
    isDone: false,
    dueDate: DateTime.now(),
    createdAt: DateTime.now(),
    notificationId: 0,
  );
  Deadline copyWith({
    String? userId,
    String? deadlineId,
    String? title,
    String? description,
    bool? isDone,
    DateTime? createdAt,
    DateTime? dueDate,
    int? notificationId,
  }) {
    return Deadline(
      userId: userId ?? this.userId,
      deadlineId: deadlineId ?? this.deadlineId,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      notificationId: notificationId?? this.notificationId,
    );
  }

  bool get isEmpty => this == Deadline.empty;

  bool get isNotEmpty => this != Deadline.empty;

  DeadlineEntity toEntity() {
    return DeadlineEntity(
      userId: userId,
      deadlineId: deadlineId,
      title: title,
      description: description,
      isDone: isDone,
      createdAt: createdAt,
      dueDate: dueDate,
      notificationId: notificationId,
    );
  }

  static Deadline fromEntity(DeadlineEntity entity) {
    return Deadline(
      userId: entity.userId,
      deadlineId: entity.deadlineId,
      title: entity.title,
      description: entity.description,
      isDone: entity.isDone,
      createdAt: entity.createdAt,
      dueDate: entity.dueDate,
      notificationId: entity.notificationId,
    );
  }

  int get remainingDays {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    // Calculate remaining days as a decimal (including fractional days)
    final remainingHours = difference.inHours;
    return (remainingHours / 24).ceil(); // This rounds up to the next full day
  }

  @override
  List<Object?> get props => [
        userId,
        deadlineId,
        title,
        description,
        isDone,
        createdAt,
        dueDate,
        notificationId,
      ];

  @override
  String toString() {
    return '''Deadline: {
      userId: $userId
      deadlineId: $deadlineId
      title: $title
      description: $description
      isDone: $isDone
      dueDate: $dueDate
      createdAt: $createdAt
      notificationId: $notificationId
    }''';
  }
}
