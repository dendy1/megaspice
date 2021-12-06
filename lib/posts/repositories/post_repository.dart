import '../posts.dart';
import 'base_post_repository.dart';

class PostRepository extends BasePostRepository {
  @override
  Future<void> createComment({required Post post, required Comment comment}) {
    // TODO: implement createComment
    throw UnimplementedError();
  }

  @override
  void createLike({required Post post, required String userId}) {
    // TODO: implement createLike
  }

  @override
  Future<void> createPost({required Post post}) {
    // TODO: implement createPost
    throw UnimplementedError();
  }

  @override
  void deleteLike({required String postId, required String userId}) {
    // TODO: implement deleteLike
  }

  @override
  Future<Set<String>> getLikedPostIds({required String userId, required List<Post> posts}) {
    // TODO: implement getLikedPostIds
    throw UnimplementedError();
  }

  @override
  Stream<List<Future<Comment>>> getPostComment({required String postId}) {
    // TODO: implement getPostComment
    throw UnimplementedError();
  }

  @override
  Future<List<Post>> getUserFeed({required String userId, required String lastPostId}) {
    // TODO: implement getUserFeed
    throw UnimplementedError();
  }

  @override
  Stream<List<Future<Post>>> getUserPosts({required String userId}) {
    // TODO: implement getUserPosts
    throw UnimplementedError();
  }
}