import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/blocs/auth_bloc/auth_bloc.dart';
import 'package:megaspice/cubit/comment_post_cubit/comment_post_cubit.dart';
import 'package:megaspice/cubit/like_post_cubit/like_post_cubit.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/repositories/repositories.dart';

part 'profile_state.dart';

part 'profile_event.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthBloc _authBloc;
  final UserRepo _userRepo;
  final PostRepo _postRepo;
  final LikePostCubit _likePostCubit;
  final CommentPostCubit _commentPostCubit;

  StreamSubscription<List<Future<PostModel?>>>? _postsSubscription;

  ProfileBloc({
    required UserRepo userRepo,
    required AuthBloc authBloc,
    required PostRepo postRepo,
    required LikePostCubit likePostCubit,
    required CommentPostCubit commentPostCubit,
  })  : _authBloc = authBloc,
        _userRepo = userRepo,
        _postRepo = postRepo,
        _likePostCubit = likePostCubit,
        _commentPostCubit = commentPostCubit,
        super(ProfileState.initial()) {
    emit(state.copyWith(userModel: authBloc.state.user));
    on<ProfileLoadEvent>(_onProfileLoad);
    on<ProfilePaginateEvent>(_onProfilePaginate);
    on<ProfileUpdatePostsEvent>(_onProfileUpdatePosts);
    on<ProfileFollowUserEvent>(_onProfileFollowUser);
    on<ProfileUnfollowUserEvent>(_onProfileUnfollowUser);
    on<ProfileDeletePostEvent>(_onProfileDeletePost);
    on<ProfileCreatePostEvent>(_onProfileCreatePost);
  }

  void _onProfileLoad(
      ProfileLoadEvent event, Emitter<ProfileState> emit) async {
    if (state.status == ProfileStatus.loaded) {
      emit(state.copyWith(status: ProfileStatus.loaded));
    } else {
      emit(state.copyWith(status: ProfileStatus.loading));
    }

    try {
      final user = await _userRepo.getUserWithId(userId: event.userId);
      final currentUserId = _authBloc.state.user.uid;

      var isCurrentUser = null;
      var isFollowing = false;
      if (currentUserId.isNotEmpty) {
        isCurrentUser = currentUserId == event.userId;
        isFollowing = await _userRepo.isFollowing(
            userId: _authBloc.state.user.uid, otherUserId: event.userId);
      }

      List<PostModel?> posts = List.empty();
      if (_postsSubscription != null) {
        _postsSubscription!.cancel();
      }
      _postsSubscription = _postRepo.getUserPostsStream(userId: event.userId).listen((futurePostList) async {
        posts = await Future.wait(futurePostList);
        add(
          ProfileUpdatePostsEvent(posts: posts, userId: user.uid),
        );
      });

      _commentPostCubit.clearAllComments();
      Map<String, CommentModel?> comments = Map();
      Map<String, int> commentsCount = Map();
      Map<String, int> postsLikes = Map();
      for (var post in posts) {
        var lastComment = await _postRepo.getLastPostComment(postId: post!.id!);
        comments[post.id!] = lastComment;
        commentsCount[post.id!] = post.comments;
        postsLikes[post.id!] = post.likes;
      }
      _commentPostCubit.updatePostComments(
          comments: comments, commentsCount: commentsCount);

      _likePostCubit.clearAllLikedPost();
      if (currentUserId.isNotEmpty) {
        final likedPostIds = await _postRepo.getLikedPostIds(
          userId: _authBloc.state.user.uid,
          posts: posts,
        );
        _likePostCubit.updateLikedPosts(
            postIds: likedPostIds, postsLikes: postsLikes);
      }

      emit(state.copyWith(
        isCurrentUser: isCurrentUser,
        isFollowing: isFollowing,
        posts: posts,
        status: ProfileStatus.loaded,
      ));
    } on FirebaseException catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        failure: Failure(message: "${e.message}"),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        failure:
            Failure(message: "failed to load this profile: " + e.toString()),
      ));
    }
  }

  void _onProfilePaginate(
      ProfilePaginateEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.paginating));
    try {
      final lastPostId = state.posts.isNotEmpty ? state.posts.last!.id : null;
      final postListPaginated = await _postRepo.getUserPosts(
        userId: event.userId,
        lastPostId: lastPostId,
      );

      Map<String, CommentModel?> comments = Map();
      Map<String, int> commentsCount = Map();
      Map<String, int> postsLikes = Map();
      for (var post in postListPaginated) {
        var lastComment = await _postRepo.getLastPostComment(postId: post!.id!);
        comments[post.id!] = lastComment;
        commentsCount[post.id!] = post.comments;
        postsLikes[post.id!] = post.likes;
      }
      _commentPostCubit.updatePostComments(
          comments: comments, commentsCount: commentsCount);

      final updatedPostList = List<PostModel?>.from(state.posts)
        ..addAll(postListPaginated);

      if (_authBloc.state.user.uid.isNotEmpty) {
        final likedPostIds = await _postRepo.getLikedPostIds(
          userId: _authBloc.state.user.uid,
          posts: postListPaginated,
        );
        _likePostCubit.updateLikedPosts(
            postIds: likedPostIds, postsLikes: postsLikes);
      }

      emit(
          state.copyWith(posts: updatedPostList, status: ProfileStatus.loaded));
    } on FirebaseException catch (e) {
      emit(state.copyWith(
          failure: Failure(message: e.message!),
          status: ProfileStatus.failure));
    } catch (e) {
      emit(state.copyWith(
          failure: Failure(message: "unable to fetch posts"),
          status: ProfileStatus.failure));
    }
  }

  void _onProfileUpdatePosts(
      ProfileUpdatePostsEvent event, Emitter<ProfileState> emit) async {
    final user = await _userRepo.getUserWithId(userId: event.userId);
    emit(state.copyWith(posts: event.posts, userModel: user));

    Map<String, CommentModel?> comments = Map();
    Map<String, int> commentsCount = Map();
    Map<String, int> postsLikes = Map();
    for (var post in event.posts) {
      var lastComment = await _postRepo.getLastPostComment(postId: post!.id!);
      comments[post.id!] = lastComment;
      commentsCount[post.id!] = post.comments;
      postsLikes[post.id!] = post.likes;
    }

    _commentPostCubit.updatePostComments(
        comments: comments, commentsCount: commentsCount);

    final likedPostIds = await _postRepo.getLikedPostIds(
      userId: _authBloc.state.user.uid,
      posts: event.posts,
    );
    _likePostCubit.updateLikedPosts(postIds: likedPostIds, postsLikes: null);
  }

  void _onProfileFollowUser(
      ProfileFollowUserEvent event, Emitter<ProfileState> emit) async {
    try {
      _userRepo.followUser(
          userId: _authBloc.state.user.uid, followUserId: state.user.uid);
      // this increment is not just for ui we use cloud function to update db
      final updatedUser =
          state.user.copyWith(followers: state.user.followers! + 1);
      emit(state.copyWith(userModel: updatedUser, isFollowing: true));
    } on FirebaseException catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        failure: Failure(
            message: e.message ?? "something went wrong! Please try again"),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        failure: Failure(message: "something went wrong! Please try again"),
      ));
    }
  }

  void _onProfileUnfollowUser(
      ProfileUnfollowUserEvent event, Emitter<ProfileState> emit) {
    try {
      _userRepo.unfollowUser(
          userId: _authBloc.state.user.uid, unfollowUserId: state.user.uid);
      //this increment is not just for ui we use cloud function to update db
      final updatedUser =
          state.user.copyWith(followers: state.user.followers! - 1);
      emit(state.copyWith(userModel: updatedUser, isFollowing: false));
    } on FirebaseException catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        failure: Failure(
            message: e.message ?? "something went wrong! Please try again"),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        failure: Failure(message: "something went wrong! Please try again"),
      ));
    }
  }

  void _onProfileCreatePost(ProfileCreatePostEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      emit(state.copyWith(status: ProfileStatus.loaded, userModel: event.post.author.copyWith(postsCount: event.post.author.posts == null ? event.post.author.posts : event.post.author.posts! + 1)));
    } on FirebaseException catch (e) {
      print("Firebase Error: ${e.message}");
      emit(state.copyWith(
          failure: Failure(message: e.message!), status: ProfileStatus.failure));
    } catch (e) {
      print("Something Unknown Error: $e");
      emit(state.copyWith(
          failure: Failure(message: "unable to fetch profile"),
          status: ProfileStatus.failure));
      print("Something Unknown Error: $e");
    }
  }

  void _onProfileDeletePost(ProfileDeletePostEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
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
        emit(state.copyWith(posts: updatedPosts, status: ProfileStatus.loaded, userModel: event.post.author.copyWith(postsCount: event.post.author.posts == null ? event.post.author.posts : event.post.author.posts! - 1)));
      }
    } on FirebaseException catch (e) {
      print("Firebase Error: ${e.message}");
      emit(state.copyWith(
          failure: Failure(message: e.message!), status: ProfileStatus.failure));
    } catch (e) {
      print("Something Unknown Error: $e");
      emit(state.copyWith(
          failure: Failure(message: "unable to fetch profile"),
          status: ProfileStatus.failure));
      print("Something Unknown Error: $e");
    }
  }
}
