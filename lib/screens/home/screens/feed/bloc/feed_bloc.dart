import 'dart:async';

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

  FeedBloc({
    required PostRepo postRepo,
    required AuthBloc authBloc,
    required LikePostCubit likePostCubit,
  })  : _postRepo = postRepo,
        _authBloc = authBloc,
        _likePostCubit = likePostCubit,
        super(
          FeedState.initial(),
        ) {
    on<FeedFetchEvent>(_onFeedFetch);
    on<FeedPaginateEvent>(_onFeedPaginate);
  }

  void _onFeedFetch(FeedFetchEvent event, Emitter<FeedState> emit) async {
    print("_onFeedFetch");
    emit(state.copyWith(posts: [], status: FeedStatus.loading));
    try {
      if (_authBloc.state.status == AuthStatus.authenticated) {
        final postList = await _postRepo.getUserFeed(userId: _authBloc.state.user.uid);
        //clearing all liked posts
        _likePostCubit.clearAllLikedPost();

        //for liked post
        final likedPostIds = await _postRepo.getLikedPostIds(
          userId: _authBloc.state.user.uid,
          posts: postList,
        );
        _likePostCubit.updateLikedPosts(postIds: likedPostIds);

        emit(state.copyWith(posts: postList, status: FeedStatus.loaded));
      } else {
        final postList = await _postRepo.getGuestFeed();
        emit(state.copyWith(posts: postList, status: FeedStatus.loaded));
      }

    } on FirebaseException catch (e) {
      print("Firebase Error: ${e.message}");
      emit(state.copyWith(
          failure: Failure(message: e.message!), status: FeedStatus.failure));
    } catch (e) {
      emit(state.copyWith(
          failure: Failure(message: "unable to fetch feeds"),
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

        //now updated post = our old fetched post + recently fetched post with pagination;
        final updatedPostList = List<PostModel?>.from(state.posts)
          ..addAll(postListPaginated);

        //for liked post
        final likedPostIds = await _postRepo.getLikedPostIds(
          userId: _authBloc.state.user.uid,
          posts: postListPaginated,
        );
        _likePostCubit.updateLikedPosts(postIds: likedPostIds);

        emit(state.copyWith(posts: updatedPostList, status: FeedStatus.loaded));
      } else {
        final lastPostId = state.posts.isNotEmpty ? state.posts.last!.id : null;
        final postList = await _postRepo.getGuestFeed(lastPostId: lastPostId);
        emit(state.copyWith(posts: List.of(state.posts)..addAll(postList), status: FeedStatus.loaded));
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
