import 'package:equatable/equatable.dart';
import 'package:subject_repository/subject_repository.dart';

class Subject extends Equatable {
  final String userId;
  final String subjectId;
  final String colorId;
  final String subjectName;

  const Subject({
    required this.userId,
    required this.subjectId,
    required this.colorId,
    required this.subjectName,
  });
  static const empty = Subject(
    userId: '',
    subjectId: '',
    colorId: '',
    subjectName: '',
  );
  Subject copyWith({
    String? userId,
    String? subjectId,
    String? colorId,
    String? subjectName,
  }) {
    return Subject(
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      colorId: colorId ?? this.colorId,
      subjectName: subjectName ?? this.subjectName,
    );
  }

  bool get isEmpty => this == Subject.empty;

  bool get isNotEmpty => this != Subject.empty;

  SubjectEntity toEntity() {
    return SubjectEntity(
      userId: userId,
      subjectId: subjectId,
      colorId: colorId,
      subjectName: subjectName,
    );
  }

  static Subject fromEntity(SubjectEntity entity) {
    return Subject(
      userId: entity.userId,
      subjectId: entity.subjectId,
      colorId: entity.colorId,
      subjectName: entity.subjectName,
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
    return '''Subject: {
      userId: $userId
      subjectId: $subjectId
      colorId:$colorId
      subjectName: $subjectName
    }''';
  }
}
