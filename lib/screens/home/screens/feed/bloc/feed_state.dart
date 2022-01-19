part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, loaded, paginating, failure }

class FeedState extends Equatable {
  final List<PostModel?> posts;
  final FeedStatus status;
  final Failure failure;
  final bool hasReachedMax;

  const FeedState({
    required this.status,
    required this.posts,
    required this.failure,
    required this.hasReachedMax,
  });

  factory FeedState.initial() {
    return FeedState(
      posts: [],
      status: FeedStatus.initial,
      failure: Failure(),
      hasReachedMax: false,
    );
  }

  FeedState copyWith({
    FeedStatus? status,
    List<PostModel?>? posts,
    Failure? failure,
    bool? hasReachedMax,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      failure: failure ?? this.failure,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status, hasReachedMax: $hasReachedMax, posts: ${posts.length} }''';
  }

  @override
  List<Object?> get props => [status, posts, failure, hasReachedMax];
}
