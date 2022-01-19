part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, paginating, loaded, failure }

class ProfileState extends Equatable {
  final User user;
  final List<PostModel?> posts;
  final bool? isCurrentUser;
  final bool isFollowing;
  final ProfileStatus status;
  final Failure failure;

  const ProfileState({
    required this.posts,
    required this.user,
    required this.isCurrentUser,
    required this.isFollowing,
    required this.status,
    required this.failure,
  });

  @override
  List<Object?> get props =>
      [posts, user, isCurrentUser, isFollowing, status, failure];

  factory ProfileState.initial() {
    return ProfileState(
      posts: [],
      user: User.empty,
      isFollowing: false,
      isCurrentUser: null,
      status: ProfileStatus.initial,
      failure: const Failure(),
    );
  }

  ProfileState copyWith({
    List<PostModel?>? posts,
    User? userModel,
    bool? isCurrentUser,
    bool? isGridView,
    bool? isFollowing,
    ProfileStatus? status,
    Failure? failure,
  }) {
    return ProfileState(
      posts: posts ?? this.posts,
      user: userModel ?? this.user,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      isFollowing: isFollowing ?? this.isFollowing,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
