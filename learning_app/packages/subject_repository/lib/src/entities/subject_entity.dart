import 'package:equatable/equatable.dart';

class SubjectEntity extends Equatable {
  final String userId;
  final String subjectId;
  final String colorId;
  final String subjectName;

  const SubjectEntity({
    required this.userId,
    required this.subjectId,
    required this.colorId,
    required this.subjectName,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'subjectId': subjectId,
      'colorId': colorId,
      'subjectName': subjectName,
    };
  }

  static SubjectEntity fromDocument(Map<String, dynamic> doc) {
    return SubjectEntity(
      userId: doc['userId'] as String,
      subjectId: doc['subjectId'] as String,
      colorId: doc['colorId'] as String,
      subjectName: doc['subjectName'] as String,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        subjectId,
        colorId,
        subjectName,
      ];

  @override
  String toString() {
    return '''SubjectEntity: {
      myUser: $userId
      subjectId: $subjectId
      colorId: $colorId
      subjectName: $subjectName
    }''';
  }
}
