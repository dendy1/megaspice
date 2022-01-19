import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:megaspice/blocs/blocs.dart';
import 'package:megaspice/cubit/cubits.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/repositories/repositories.dart';

part 'feed_event.dart';

part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostRepo _postRepo;
  final AuthBloc _authBloc;
  final LikePostCubit _likePostCubit;
  final CommentPostCubit _commentPostCubit;

  FeedBloc({
    required PostRepo postRepo,
    required AuthBloc authBloc,
    required LikePostCubit likePostCubit,
    required CommentPostCubit commentPostCubit,
  })  : _postRepo = postRepo,
        _authBloc = authBloc,
        _likePostCubit = likePostCubit,
        _commentPostCubit = commentPostCubit,
        super(
          FeedState.initial(),
        ) {
    on<FeedFetchEvent>(_onFeedFetch);
    on<FeedPaginateEvent>(_onFeedPaginate);
    on<FeedDeletePostEvent>(_onFeedDeletePost);
  }

  void _onFeedFetch(FeedFetchEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(posts: [], status: FeedStatus.loading));
    try {
      if (_authBloc.state.status == AuthStatus.authenticated) {
        final postList =
            await _postRepo.getUserFeed(userId: _authBloc.state.user.uid);

        _commentPostCubit.clearAllComments();
        _likePostCubit.clearAllLikedPost();

        Map<String, CommentModel?> comments = Map();
        Map<String, int> commentsCount = Map();
        Map<String, int> postsLikes = Map();
        for (var post in postList) {
          var lastComment =
              await _postRepo.getLastPostComment(postId: post!.id!);
          comments[post.id!] = lastComment;
          commentsCount[post.id!] = post.comments;
          postsLikes[post.id!] = post.likes;
        }
        _commentPostCubit.updatePostComments(
            comments: comments, commentsCount: commentsCount);

        final likedPostIds = await _postRepo.getLikedPostIds(
          userId: _authBloc.state.user.uid,
          posts: postList,
        );
        _likePostCubit.updateLikedPosts(
            postIds: likedPostIds, postsLikes: postsLikes);

        emit(state.copyWith(posts: postList, status: FeedStatus.loaded));
      } else {
        final postList = await _postRepo.getGuestFeed();

        _commentPostCubit.clearAllComments();
        Map<String, CommentModel?> comments = Map();
        Map<String, int> commentsCount = Map();
        Map<String, int> postsLikes = Map();
        for (var post in postList) {
          var lastComment =
              await _postRepo.getLastPostComment(postId: post!.id!);
          comments[post.id!] = lastComment;
          commentsCount[post.id!] = post.comments;
          postsLikes[post.id!] = post.likes;
        }
        _commentPostCubit.updatePostComments(
            comments: comments, commentsCount: commentsCount);
        _likePostCubit.updateLikedPosts(
            postIds: {}, postsLikes: postsLikes);

        emit(state.copyWith(posts: postList, status: FeedStatus.loaded));
      }
    } on FirebaseException catch (e) {
      emit(state.copyWith(
          failure: Failure(message: e.message!), status: FeedStatus.failure));
    } catch (e) {
      emit(state.copyWith(
          failure: Failure(message: "unable to fetch feeds: $e"),
          status: FeedStatus.failure));
      print("Something Unknown Error: $e");
    }
  }

  void _onFeedPaginate(FeedPaginateEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.paginating));
    try {
      if (_authBloc.state.status == AuthStatus.authenticated) {
        final lastPostId = state.posts.isNotEmpty ? state.posts.last!.id : null;
        final postListPaginated = await _postRepo.getUserFeed(
          userId: _authBloc.state.user.uid,
          lastPostId: lastPostId,
        );

        Map<String, CommentModel?> comments = Map();
        Map<String, int> commentsCount = Map();
        Map<String, int> postsLikes = Map();
        for (var post in postListPaginated) {
          var lastComment =
              await _postRepo.getLastPostComment(postId: post!.id!);
          comments[post.id!] = lastComment;
          commentsCount[post.id!] = post.comments;
          postsLikes[post.id!] = post.likes;
        }
        _commentPostCubit.updatePostComments(
            comments: comments, commentsCount: commentsCount);

        //now updated post = our old fetched post + recently fetched post with pagination;
        final updatedPostList = List<PostModel?>.from(state.posts)
          ..addAll(postListPaginated);

        //for liked post
        final likedPostIds = await _postRepo.getLikedPostIds(
          userId: _authBloc.state.user.uid,
          posts: postListPaginated,
        );
        _likePostCubit.updateLikedPosts(
            postIds: likedPostIds, postsLikes: postsLikes);

        emit(state.copyWith(posts: updatedPostList, status: FeedStatus.loaded));
      } else {
        final lastPostId = state.posts.isNotEmpty ? state.posts.last!.id : null;
        final postList = await _postRepo.getGuestFeed(lastPostId: lastPostId);

        Map<String, CommentModel?> comments = Map();
        Map<String, int> commentsCount = Map();
        Map<String, int> postsLikes = Map();
        for (var post in postList) {
          var lastComment =
              await _postRepo.getLastPostComment(postId: post!.id!);
          comments[post.id!] = lastComment;
          commentsCount[post.id!] = post.comments;
          postsLikes[post.id!] = post.likes;
        }

        _commentPostCubit.updatePostComments(
            comments: comments, commentsCount: commentsCount);
        _likePostCubit.updateLikedPosts(
            postIds: {}, postsLikes: postsLikes);

        emit(state.copyWith(
            posts: List.of(state.posts)..addAll(postList),
            status: FeedStatus.loaded));
      }
    } on FirebaseException catch (e) {
      print("Firebase Error: ${e.message}");
      emit(state.copyWith(
          failure: Failure(message: e.message!), status: FeedStatus.failure));
    } catch (e) {
      print("Something Unknown Error: $e");
      emit(state.copyWith(
          failure: Failure(message: "unable to fetch feeds"),
          status: FeedStatus.failure));
      print("Something Unknown Error: $e");
    }
  }

  void _onFeedDeletePost(FeedDeletePostEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.paginating));
    try {
      final currentUserId = _authBloc.state.user.uid;
      if (currentUserId == event.post.author.uid) {
        _postRepo.deletePost(post: event.post);

        var updatedComments = Map<String, CommentModel?>.from(_commentPostCubit.state.comments);
        updatedComments.remove(event.post.id);

        var updatedCommentsCount = Map<String, int>.from(_commentPostCubit.state.commentsCount);
        updatedCommentsCount.remove(event.post.id);
        _commentPostCubit.updatePostComments(
            comments: updatedComments, commentsCount: updatedCommentsCount);

        var updatedLikedPostIds = Set<String>.from(_likePostCubit.state.likedPostIds);
        updatedLikedPostIds.remove(event.post.id);

        var updatedPostsLikes = Map<String, int>.from(_likePostCubit.state.postsLikes);
        updatedPostsLikes.remove(event.post.id);
        _likePostCubit.updateLikedPosts(
            postIds: updatedLikedPostIds, postsLikes: updatedPostsLikes);

        var updatedPosts = List<PostModel?>.from(state.posts);
        updatedPosts.remove(event.post);
        emit(state.copyWith(posts: updatedPosts, status: FeedStatus.loaded));
      }
    } on FirebaseException catch (e) {
      print("Firebase Error: ${e.message}");
      emit(state.copyWith(
          failure: Failure(message: e.message!), status: FeedStatus.failure));
    } catch (e) {
      print("Something Unknown Error: $e");
      emit(state.copyWith(
          failure: Failure(message: "unable to fetch feeds"),
          status: FeedStatus.failure));
      print("Something Unknown Error: $e");
    }
  }
}
