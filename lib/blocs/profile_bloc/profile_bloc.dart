import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/blocs/auth_bloc/auth_bloc.dart';
import 'package:megaspice/cubit/like_post_cubit/like_post_cubit.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/repositories/repositories.dart';

part 'profile_state.dart';

part 'profile_event.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthBloc _authBloc;
  final LikePostCubit _likePostCubit;
  final UserRepo _userRepo;
  final PostRepo _postRepo;
  StreamSubscription<List<Future<PostModel?>>>? _postsSubscription;

  ProfileBloc({
    required UserRepo userRepo,
    required AuthBloc authBloc,
    required PostRepo postRepo,
    required LikePostCubit likePostCubit,
  })  : _authBloc = authBloc,
        _userRepo = userRepo,
        _postRepo = postRepo,
        _likePostCubit = likePostCubit,
        super(ProfileState.initial()) {
    on<ProfileLoadEvent>(_onProfileLoad);
    on<ProfileUpdatePostsEvent>(_onProfileUpdatePosts);
    on<ProfileFollowUserEvent>(_onProfileFollowUser);
    on<ProfileUnfollowUserEvent>(_onProfileUnfollowUser);
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

      _postsSubscription?.cancel();
      _postsSubscription = _postRepo
          .getUserPosts(userId: event.userId)
          .listen((futurePostList) async {
        final allPosts = await Future.wait(futurePostList);
        add(
          ProfileUpdatePostsEvent(posts: allPosts),
        );
      });

      emit(state.copyWith(
        userModel: user,
        isCurrentUser: isCurrentUser,
        isFollowing: isFollowing,
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
        failure: const Failure(message: "Unable to load this profile"),
      ));
    }
  }

  void _onProfileUpdatePosts(
      ProfileUpdatePostsEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(posts: event.posts));
    //for liked post
    final likedPostIds = await _postRepo.getLikedPostIds(
      userId: _authBloc.state.user.uid,
      posts: event.posts,
    );
    _likePostCubit.updateLikedPosts(postIds: likedPostIds);
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

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }
}
