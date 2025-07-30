import 'package:equatable/equatable.dart';
import 'package:studyplan_repository/studyplan_repository.dart';


class Studyplan extends Equatable {
  final String userId;
  final String studyplanId;
  final String cardColor;
  final String subjectName;
  final DateTime planDate;
  final int durationInMin;
  final DateTime createdAt; // Add this field

  const Studyplan({
    required this.userId,
    required this.studyplanId,
    required this.cardColor,
    required this.subjectName,
    required this.planDate,
    required this.durationInMin,
    required this.createdAt, // Add this field
  });

  static final empty = Studyplan(
    userId: '',
    studyplanId: '',
    cardColor: '',
    subjectName: '',
    planDate: DateTime.now(),
    durationInMin: 0,
    createdAt: DateTime.now(),
  );

  Studyplan copyWith({
    String? userId,
    String? studyplanId,
    String? cardColor,
    String? subjectName,
    DateTime? planDate,
    int? durationInMin,
    DateTime? createdAt,
  }) {
    return Studyplan(
      userId: userId ?? this.userId,
      studyplanId: studyplanId ?? this.studyplanId,
      cardColor: cardColor ?? this.cardColor,
      subjectName: subjectName ?? this.subjectName,
      planDate: planDate ?? this.planDate,
      durationInMin: durationInMin ?? this.durationInMin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  StudyplanEntity toEntity() {
    return StudyplanEntity(
      userId: userId,
      studyplanId: studyplanId,
      cardColor: cardColor,
      subjectName: subjectName,
      planDate: planDate,
      durationInMin: durationInMin,
      createdAt: createdAt,
    );
  }

  static Studyplan fromEntity(StudyplanEntity entity) {
    return Studyplan(
      userId: entity.userId,
      studyplanId: entity.studyplanId,
      cardColor: entity.cardColor,
      subjectName: entity.subjectName,
      planDate: entity.planDate,
      durationInMin: entity.durationInMin,
      createdAt: entity.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        studyplanId,
        cardColor,
        subjectName,
        planDate,
        durationInMin,
        createdAt,
      ];
}