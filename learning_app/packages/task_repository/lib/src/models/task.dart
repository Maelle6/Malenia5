import 'package:equatable/equatable.dart';
import 'package:task_repository/task_repository.dart';

class Task extends Equatable {
  final String userId;
  final String taskId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isDone;
  final DateTime createdAt;
  final int notificationId;

  const Task({
    required this.userId,
    required this.taskId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isDone,
    required this.createdAt,
    required this.notificationId,
  });
  static final empty = Task(
    userId: '',
    taskId: '',
    title: '',
    description: '',
    dueDate: DateTime.now(),
    isDone: false,
    createdAt: DateTime.now(),
    notificationId: 0,
  );
  Task copyWith({
    String? userId,
    String? taskId,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isDone,
    int? notificationId,
  }) {
    return Task(
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  bool get isEmpty => this == Task.empty;

  bool get isNotEmpty => this != Task.empty;

  TaskEntity toEntity() {
    return TaskEntity(
      userId: userId,
      taskId: taskId,
      title: title,
      description: description,
      createdAt: createdAt,
      dueDate: dueDate,
      isDone: isDone,
      notificationId: notificationId,
    );
  }

  static Task fromEntity(TaskEntity entity) {
    return Task(
      userId: entity.userId,
      taskId: entity.taskId,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
      dueDate: entity.dueDate,
      isDone: entity.isDone,
      notificationId: entity.notificationId,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        taskId,
        title,
        description,
        createdAt,
        dueDate,
        isDone,
        notificationId,
      ];

  @override
  String toString() {
    return '''Task: {
      userId: $userId
      taskId: $taskId
      title: $title
      description: $description
      dueDate: $dueDate
      isDone: $isDone
      createdAt: $createdAt
      notificationId: $notificationId
    }''';
  }
}
