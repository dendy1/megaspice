import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/cubit/cubits.dart';
import 'package:megaspice/models/models.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final LikePostCubit _likePostCubit;

  PostCubit({
    required PostModel post,
    required bool isLiked,
    required LikePostCubit likePostCubit,
  })  : _likePostCubit = likePostCubit,
        super(PostState(post: post, isLiked: isLiked));

  void likePost() {
    if (state.isLiked) {
      _likePostCubit.unLikePost(post: state.post);
      emit(state.copyWith(isLiked: false));
    } else {
      _likePostCubit.likePost(post: state.post);
      emit(state.copyWith(isLiked: true));
    }
  }
}
