import 'package:megaspice/models/models.dart';

abstract class BasePostRepo {
  Future<void> createPost({
    required PostModel post,
  });

  Future<void> deletePost({
    required PostModel post,
  });

  Future<void> createComment({
    required PostModel post,
    required CommentModel comment,
  });

  Future<void> deleteComment({
    required PostModel post,
    required CommentModel comment,
  });

  void createLike({
    required PostModel post,
    required String userId,
  });

  Future<List<PostModel?>> getUserPosts({
    required String userId,
    String lastPostId,
  });

  Stream<List<Future<CommentModel?>>> getPostCommentsStream({
    required String postId,
  });

  Future<CommentModel?> getLastPostComment({
    required String postId,
  });

  Future<List<PostModel?>> getUserFeed({
    required String userId,
    String lastPostId,
  });

  Future<List<PostModel?>> getGuestFeed({
    String lastPostId,
  });

  Future<Set<String>> getLikedPostIds({
    required String userId,
    required List<PostModel> posts,
  });

  void deleteLike({
    required PostModel post,
    required String userId,
  });
}
