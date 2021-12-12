part of 'feed_bloc.dart';

enum FeedStatus { initial, success, failure }

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const <Post>[],
    this.hasReachedMax = false,
  });

  final FeedStatus status;
  final List<Post> posts;
  final bool hasReachedMax;

  FeedState copyWith({
    FeedStatus? status,
    List<Post>? posts,
    bool? hasReachedMax,
  }) {
    return FeedState(
        status: status ?? this.status,
        posts: posts ?? this.posts,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status, hasReachedMax: $hasReachedMax, posts: ${posts.length} }''';
  }

  @override
  List<Object?> get props => [status, posts, hasReachedMax];
}