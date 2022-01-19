import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uid;
  final String? username;
  final String? email;
  final String? photo;
  final String? displayName;
  final String? gender;
  final DateTime? dateOfBirth;
  final int? followers;
  final int? following;
  final int? posts;
  final bool? disabled;

  const User({
    required this.uid,
    this.username,
    this.email,
    this.photo,
    this.displayName,
    this.gender,
    this.dateOfBirth,
    this.followers,
    this.following,
    this.posts,
    this.disabled,
  });

  static const empty = User(
    uid: '',
    username: '',
    email: '',
    photo: '',
    displayName: '',
    gender: '',
    dateOfBirth: null,
    followers: 0,
    following: 0,
    posts: 0,
    disabled: false,
  );

  bool get isEmpty => this == User.empty;

  bool get isNotEmpty => this != User.empty;

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? photo,
    String? name,
    String? gender,
    DateTime? dateOfBirth,
    int? followers,
    int? following,
    int? postsCount,
    bool? disabled,
  }) {
    return new User(
      uid: id ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: name ?? this.displayName,
      photo: photo ?? this.photo,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      posts: postsCount ?? this.posts,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        username,
        email,
        photo,
        displayName,
        gender,
        dateOfBirth,
        followers,
        following,
        posts,
        disabled
      ];

  Map<String, dynamic> toDocument() {
    if (dateOfBirth == null) {
      return {
        'uid': uid,
        'username': username ?? '',
        'email': email ?? '',
        'photo': photo ?? '',
        'name': displayName ?? '',
        'gender': gender ?? '',
        'followers': followers ?? 0,
        'following': following ?? 0,
        'posts': posts ?? 0,
        'disabled': disabled ?? false,
      };
    } else {
      return {
        'uid': uid,
        'username': username ?? '',
        'email': email ?? '',
        'photo': photo ?? '',
        'name': displayName ?? '',
        'gender': gender ?? '',
        'dateOfBirth': dateOfBirth,
        'followers': followers ?? 0,
        'following': following ?? 0,
        'posts': posts ?? 0,
        'disabled': disabled ?? false,
      };
    }
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    var dateOfBirth = null;
    try {
      dateOfBirth = DateTime.fromMillisecondsSinceEpoch(
          (doc.get('dateOfBirth') as Timestamp).millisecondsSinceEpoch);
    } catch (e) {}

    var disabled = false;
    try {
      disabled = doc.get('disabled');
    } catch (e) {}


    return User(
      uid: doc.id,
      username: doc.get('username'),
      email: doc.get('email'),
      photo: doc.get('photo'),
      displayName: doc.get('name'),
      gender: doc.get('gender'),
      dateOfBirth: dateOfBirth,
      following: doc.get('following'),
      followers: doc.get('followers'),
      posts: doc.get('posts'),
      disabled: disabled,
    );
  }
}
