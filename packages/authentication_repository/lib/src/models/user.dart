import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? email;
  final String? username;
  final String? name;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? photo;

  const User({
    required this.id,
    this.email,
    this.username,
    this.name,
    this.gender,
    this.dateOfBirth,
    this.photo,
  });

  static const empty = User(id: '');

  bool get isEmpty => this == User.empty;
  bool get isNotEmpty => this != User.empty;

  @override
  List<Object?> get props => [id, email, username, gender, dateOfBirth, photo];
}
