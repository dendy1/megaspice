part of 'comment_post_cubit.dart';

class CommentPostState extends Equatable {
  final Map<String, CommentModel?> comments;
  final Map<String, int> commentsCount;

  const CommentPostState({
    required this.comments,
    required this.commentsCount,
  });

  factory CommentPostState.initial() {
    return CommentPostState(
      comments: Map(),
      commentsCount: Map()
    );
  }

  CommentPostState copyWith({
    Map<String, CommentModel?>? comments,
    Map<String, int>? commentsCount,
  }) {
    return new CommentPostState(
      comments: comments ?? this.comments,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  @override
  List<Object> get props => [comments, commentsCount];
}