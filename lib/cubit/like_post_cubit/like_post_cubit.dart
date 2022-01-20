import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/blocs/blocs.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/repositories/post/post_repository.dart';

part 'like_post_state.dart';

class LikePostCubit extends Cubit<LikePostState> {
  final PostRepo _postRepo;
  final AuthBloc _authBloc;

  LikePostCubit({
    required PostRepo postRepo,
    required AuthBloc authBloc,
  })  : _postRepo = postRepo,
        _authBloc = authBloc,
        super(LikePostState.initial());

  void updateLikedPosts({
    required Set<String> postIds,
    required Map<String, int>? postsLikes,
  }) {
    if (postsLikes == null) {
      emit(state.copyWith(
        likedPostIds: Set<String>.from(state.likedPostIds)..addAll(postIds),
      ));
    } else {
      emit(state.copyWith(
        likedPostIds: Set<String>.from(state.likedPostIds)..addAll(postIds),
        postsLikes: Map<String, int>.from(state.postsLikes)..addAll(postsLikes),
      ));
    }
  }

  void likePost({
    required PostModel post,
  }) {
    if (_authBloc.state.user.uid.isEmpty) {
      return;
    }
    _postRepo.createLike(post: post, userId: _authBloc.state.user.uid);

    final updatedPostsLikes = Map<String, int>.from(state.postsLikes);
    if (updatedPostsLikes.containsKey(post.id)) {
      updatedPostsLikes[post.id!] = updatedPostsLikes[post.id]! + 1;
    } else {
      updatedPostsLikes[post.id!] = 1;
    }

    emit(state.copyWith(
      likedPostIds: Set<String>.from(state.likedPostIds)..add(post.id!),
      postsLikes: updatedPostsLikes,
    ));
  }

  void unLikePost({
    required PostModel post,
  }) {
    if (_authBloc.state.user.uid.isEmpty) {
      return;
    }
    _postRepo.deleteLike(post: post, userId: _authBloc.state.user.uid);
    final updatedPostsLikes = Map<String, int>.from(state.postsLikes);
    if (updatedPostsLikes.containsKey(post.id)) {
      updatedPostsLikes[post.id!] = updatedPostsLikes[post.id]! - 1;
    }

    emit(state.copyWith(
      likedPostIds: Set<String>.from(state.likedPostIds)..remove(post.id),
      postsLikes: updatedPostsLikes,
    ));
  }

  void clearAllLikedPost() {
    emit(LikePostState.initial());
  }
}
