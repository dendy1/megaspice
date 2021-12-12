import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String gender;
  final DateTime dateOfBirth;
  final String imageUrl;

  const User({
    required this.id,
    required this.username,
    required this.gender,
    required this.dateOfBirth,
    required this.imageUrl,
  });

  User copyWith({
    required String id,
    required String username,
    required String gender,
    required DateTime dateOfBirth,
    required String imageUrl,
  }) {
    return new User(
      id: id,
      username: username,
      gender: gender,
      dateOfBirth: dateOfBirth,
      imageUrl: imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, username, gender, dateOfBirth, imageUrl];
}