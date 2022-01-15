import 'package:megaspice/models/models.dart';

abstract class BasePostRepo {
  Future<void> createPost({required PostModel postModel});

  Future<void> createComment({
    required PostModel postModel,
    required CommentModel commentModel,
  });

  void createLike({
    required PostModel postModel,
    required String userId,
  });

  Stream<List<Future<PostModel?>>> getUserPosts({
    required String userId,
  });

  Stream<List<Future<CommentModel?>>> getPostComment({
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
    required String postId,
    required String userId,
  });
}
