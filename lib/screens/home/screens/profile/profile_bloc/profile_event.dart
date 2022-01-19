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

class ProfilePaginateEvent extends ProfileEvent {
  final String userId;

  ProfilePaginateEvent({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];
}

class ProfileUpdatePostsEvent extends ProfileEvent {
  final String userId;
  final List<PostModel?> posts;

  ProfileUpdatePostsEvent({
    required this.userId,
    required this.posts,
  });

  @override
  List<Object> get props => [posts];
}

class ProfileFollowUserEvent extends ProfileEvent {}

class ProfileUnfollowUserEvent extends ProfileEvent {}

class ProfileDeletePostEvent extends ProfileEvent {
  final PostModel post;

  ProfileDeletePostEvent({
    required this.post,
  });

  @override
  List<Object> get props => [post];
}

class ProfileCreatePostEvent extends ProfileEvent {
  final PostModel post;

  ProfileCreatePostEvent({
    required this.post,
  });

  @override
  List<Object> get props => [post];
}