import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/blocs/blocs.dart';
import 'package:megaspice/constants/firebase_constants.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/repositories/repositories.dart';

part 'comment_post_state.dart';

class CommentPostCubit extends Cubit<CommentPostState> {
  final PostRepo _postRepo;
  final AuthBloc _authBloc;

  CommentPostCubit({
    required PostRepo postRepo,
    required AuthBloc authBloc,
  })
      : _postRepo = postRepo,
        _authBloc = authBloc,
        super(CommentPostState.initial());

  void updatePostComments({
    required Map<String, CommentModel?> comments,
    required Map<String, int> commentsCount,
  }) {
    emit(state.copyWith(
      comments: Map<String, CommentModel?>.from(state.comments)..addAll(comments),
      commentsCount: Map<String, int>.from(state.commentsCount)..addAll(commentsCount),
    ));
  }

  void createComment({
    required PostModel post,
    required CommentModel comment,
  }) async {
    if (_authBloc.state.user.uid.isEmpty) {
      return;
    }

    var updatedComments = Map<String, CommentModel?>.from(state.comments);
    updatedComments[post.id!] = comment;

    var updatedCommentsCount = Map<String, int>.from(state.commentsCount);
    if (updatedCommentsCount.containsKey(post.id!)) {
      updatedCommentsCount[post.id!] = updatedCommentsCount[post.id!]! + 1;
    } else {
      updatedCommentsCount[post.id!] = 1;
    }
    emit(state.copyWith(comments: updatedComments, commentsCount: updatedCommentsCount));
  }

  void deleteComment({
    required PostModel post,
    required CommentModel comment,
    required CommentModel? previousComment,
  }) async {
    if (_authBloc.state.user.uid.isEmpty) {
      return;
    }

    var updatedComments = Map<String, CommentModel?>.from(state.comments);
    updatedComments[post.id!] = previousComment;

    var updatedCommentsCount = Map<String, int>.from(state.commentsCount);
    if (updatedCommentsCount.containsKey(post.id!)) {
      updatedCommentsCount[post.id!] = updatedCommentsCount[post.id!]! - 1;
    }
    emit(state.copyWith(comments: updatedComments, commentsCount: updatedCommentsCount));
  }

  void clearAllComments() {
    emit(CommentPostState.initial());
  }
}
