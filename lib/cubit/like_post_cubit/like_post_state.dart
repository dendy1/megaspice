part of 'like_post_cubit.dart';

class LikePostState extends Equatable {
  final Set<String> likedPostIds;
  final Map<String, int> postsLikes;

  const LikePostState({
    required this.likedPostIds,
    required this.postsLikes,
  });

  factory LikePostState.initial() {
    return LikePostState(
      likedPostIds: {},
      postsLikes: Map(),
    );
  }

  LikePostState copyWith({
    Set<String>? likedPostIds,
    Map<String, int>? postsLikes,
  }) {
    return new LikePostState(
      likedPostIds: likedPostIds ?? this.likedPostIds,
      postsLikes: postsLikes ?? this.postsLikes,
    );
  }

  @override
  List<Object> get props => [likedPostIds, postsLikes];
}
