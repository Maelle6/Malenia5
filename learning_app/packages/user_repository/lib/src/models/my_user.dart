import 'package:equatable/equatable.dart';
import '../entities/entities.dart';

class MyUser extends Equatable {
  final String id;
  final String email;
  final String? first_name;
  final String? last_name;
  final String username;
  final int? age;
  final String? gender;
  final String? profileImage;

  const MyUser({
    required this.id,
    required this.email,
    this.first_name,
    this.last_name,
    this.age,
    required this.username,
    this.gender,
    this.profileImage,
  });

  static const empty = MyUser(
    id: '',
    email: '',
    first_name: '',
    last_name: '',
    username: '',
    age: 0,
    gender: '',
    profileImage: '',
  );

  MyUser copyWith({
    String? id,
    String? email,
    String? first_name,
    String? last_name,
    String? username,
    int? age,
    String? gender,
    String? profileImage,
  }) {
    return MyUser(
      id: id ?? this.id,
      email: email ?? this.email,
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      username: username ?? this.username,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  bool get isEmpty => this == MyUser.empty;
  bool get isNotEmpty => this != MyUser.empty;

  MyUserEntity toEntity() {
    return MyUserEntity(
      id: id,
      email: email,
      first_name: first_name,
      last_name: last_name,
      username: username,
      age: age,
      gender: gender,
      profileImage: profileImage,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      id: entity.id,
      email: entity.email,
      first_name: entity.first_name,
      last_name: entity.last_name,
      username: entity.username,
      age: entity.age,
      gender: entity.gender,
      profileImage: entity.profileImage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        first_name,
        last_name,
        username,
        age,
        gender,
        profileImage,
      ];
}
