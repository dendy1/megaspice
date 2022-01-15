part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ProfileLoadEvent extends ProfileEvent {
  final String userId;

  ProfileLoadEvent({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];
}

class ProfileUpdatePostsEvent extends ProfileEvent {
  final List<PostModel?> posts;

  ProfileUpdatePostsEvent({
    required this.posts,
  });

  @override
  List<Object> get props => [posts];
}

class ProfileFollowUserEvent extends ProfileEvent {}

class ProfileUnfollowUserEvent extends ProfileEvent {}
