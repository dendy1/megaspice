part of 'post_cubit.dart';

class PostState extends Equatable {
  final PostModel post;
  final bool isLiked;

  const PostState({
    required this.post,
    required this.isLiked,
  });

  PostState copyWith({
    PostModel? post,
    bool? isLiked,
  }) {
    return new PostState(
      post: post ?? this.post,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [post, isLiked];
}
