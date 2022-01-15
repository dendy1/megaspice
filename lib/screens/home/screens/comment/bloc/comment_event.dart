part of 'comment_bloc.dart';

abstract class CommentEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchCommentEvent extends CommentEvent {
  final PostModel post;

  FetchCommentEvent({
    required this.post,
  });

  @override
  List<Object> get props => [post];
}

class UpdateCommentsEvent extends CommentEvent {
  final List<CommentModel?> commentList;

  UpdateCommentsEvent({
    required this.commentList,
  });

  @override
  List<Object> get props => [commentList];
}

class PostCommentsEvent extends CommentEvent {
  final String content;

  PostCommentsEvent({
    required this.content,
  });

  @override
  List<Object> get props => [content];
}
