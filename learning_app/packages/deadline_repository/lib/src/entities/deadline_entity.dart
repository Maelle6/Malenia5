import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DeadlineEntity extends Equatable {
  final String userId;
  final String deadlineId;
  final String title;
  final String description;
  final bool isDone;
  final DateTime dueDate;
  final DateTime createdAt;
  final int notificationId;

  const DeadlineEntity({
    required this.userId,
    required this.deadlineId,
    required this.title,
    required this.description,
    required this.isDone,
    required this.dueDate,
    required this.createdAt,
    required this.notificationId,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'deadlineId': deadlineId,
      'title': title,
      'description': description,
      'isDone': isDone,
      'dueDate': dueDate,
      'createdAt': createdAt,
      'notificationId': notificationId,
    };
  }

  static DeadlineEntity fromDocument(Map<String, dynamic> doc) {
    return DeadlineEntity(
      userId: doc['userId'] as String,
      deadlineId: doc['deadlineId'] as String,
      title: doc['title'] as String,
      description: doc['description'] as String,
      isDone: doc['isDone'] as bool,
      dueDate: (doc['dueDate'] as Timestamp).toDate(),
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
      notificationId: doc['notificationId'] as int,
    );
  }

  @override
  List<Object?> get props => [
        deadlineId,
        title,
        description,
        isDone,
        createdAt,
        dueDate,
        userId,
        notificationId,
      ];

  @override
  String toString() {
    return '''DeadlineEntity: {
      deadlineId: $deadlineId
      title: $title
      description: $description
      isDone: $isDone
      dueDate: $dueDate
      createdAt: $createdAt
      myUser: $userId
      notificationId: $notificationId
    }''';
  }
}
