import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/blocs/blocs.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/repositories/post/post_repository.dart';

part 'like_post_state.dart';

class LikePostCubit extends Cubit<LikePostState> {
  final PostRepo _postRepository;
  final AuthBloc _authBloc;

  LikePostCubit({
    required PostRepo postRepository,
    required AuthBloc authBloc,
  })  : _postRepository = postRepository,
        _authBloc = authBloc,
        super(LikePostState.initial());

  //we can use this method to fetch initial like post while loading initial feed
  void updateLikedPosts({
    required Set<String> postIds,
  }) {
    emit(state.copyWith(
      likedPostIds: Set<String>.from(state.likedPostIds)..addAll(postIds),
    ));
  }

  void likePost({
    required PostModel postModel,
  }) {
    if (_authBloc.state.user == null) {
      return;
    }
    _postRepository.createLike(
        postModel: postModel, userId: _authBloc.state.user.uid);
    emit(state.copyWith(
      likedPostIds: Set<String>.from(state.likedPostIds)..add(postModel.id!),
      recentlyLikedPostsIds: Set<String>.from(state.recentlyLikedPostsIds)
        ..add(postModel.id!),
    ));
  }

  void unLikePost({
    required PostModel postModel,
  }) {
    if (_authBloc.state.user == null) {
      return;
    }
    _postRepository.deleteLike(
        postId: postModel.id!, userId: _authBloc.state.user.uid);
    emit(state.copyWith(
      likedPostIds: Set<String>.from(state.likedPostIds)..remove(postModel.id),
      recentlyLikedPostsIds: Set<String>.from(state.recentlyLikedPostsIds)
        ..remove(postModel.id),
    ));
  }

  void clearAllLikedPost() {
    emit(LikePostState.initial());
  }
}
