import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class StudyplanEntity extends Equatable {
  final String userId;
  final String studyplanId;
  final String cardColor;
  final String subjectName;
  final DateTime planDate;
  final int durationInMin;
  final DateTime createdAt; // Add this field

  const StudyplanEntity({
    required this.userId,
    required this.studyplanId,
    required this.cardColor,
    required this.subjectName,
    required this.planDate,
    required this.durationInMin,
    required this.createdAt, // Add this field
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'studyplanId': studyplanId,
      'cardColor': cardColor,
      'subjectName': subjectName,
      'planDate': planDate,
      'durationInMin': durationInMin,
      'createdAt': createdAt,
    };
  }

  static StudyplanEntity fromDocument(Map<String, dynamic> doc) {
    return StudyplanEntity(
      userId: doc['userId'] as String,
      studyplanId: doc['studyplanId'] as String,
      cardColor: doc['cardColor'] as String,
      subjectName: doc['subjectName'] as String,
      planDate: (doc['planDate'] as Timestamp).toDate(),
      durationInMin: doc['durationInMin'] as int,
      createdAt: (doc['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        studyplanId,
        cardColor,
        subjectName,
        planDate,
        durationInMin,
        userId,
        createdAt,
      ];
}