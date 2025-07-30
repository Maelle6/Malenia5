import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String userId;
  final String taskId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isDone;
  final DateTime createdAt;
  final int notificationId;

  const TaskEntity({
    required this.userId,
    required this.taskId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isDone,
    required this.createdAt,
    required this.notificationId,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'taskId': taskId,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'isDone': isDone,
      'createdAt': createdAt,
      'notificationId': notificationId,
    };
  }

  static TaskEntity fromDocument(Map<String, dynamic> doc) {
    return TaskEntity(
      userId: doc['userId'] as String,
      taskId: doc['taskId'] as String,
      title: doc['title'] as String,
      description: doc['description'] as String,
      dueDate: (doc['dueDate'] as Timestamp).toDate(),
      isDone: doc['isDone'] as bool,
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
      notificationId: doc['notificationId'] as int,
    );
  }

  @override
  List<Object?> get props => [
        taskId,
        title,
        description,
        createdAt,
        dueDate,
        isDone,
        userId,
        notificationId,
      ];

  @override
  String toString() {
    return '''TaskEntity: {
      taskId: $taskId
      title: $title
      description: $description
      dueDate: $dueDate
      isDone: $isDone
      createdAt: $createdAt
      myUser: $userId
      notificationId: $notificationId
    }''';
  }
}
