import 'package:equatable/equatable.dart';

class MyUserEntity extends Equatable {
  final String id;
  final String email;
  final String? first_name;
  final String? last_name;
  final String username;
  final int? age;
  final String? gender;
  final String? profileImage;

  const MyUserEntity({
    required this.id,
    required this.email,
    this.first_name,
    this.last_name,
    required this.username,
    this.age,
    this.gender,
    this.profileImage,
  });

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'email': email,
      'first_name': first_name,
      'last_name': last_name,
      'username': username,
      'age': age,
      'gender': gender,
      'profileImage': profileImage,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
      id: doc['id'] as String,
      email: doc['email'] as String,
      first_name: doc['first_name'] as String,
      last_name: doc['last_name'] as String,
      username: doc['username'] as String,
      gender: doc['gender'] as String,
      age: doc['age'] as int,
      profileImage: doc['profileImage'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        first_name,
        last_name,
        username,
        gender,
        age,
        profileImage,
      ];

  @override
  String toString() {
    return '''UserEntity: {
      id: $id,
      email: $email,
      first_name: $first_name,
      last_name: $last_name,
      username: $username,
      gender: $gender,
      age: $age,
      profileImage: $profileImage,
    }''';
  }
}
