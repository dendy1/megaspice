import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/blocs/blocs.dart';
import 'package:megaspice/cubit/cubits.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/repositories/post/post_repository.dart';

part 'comment_event.dart';

part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final PostRepo _postRepo;
  final AuthBloc _authBloc;
  final CommentPostCubit _commentPostCubit;
  StreamSubscription<List<Future<CommentModel?>>>? _commentSubscription;

  CommentBloc({
    required PostRepo postRepo,
    required AuthBloc authBloc,
    required CommentPostCubit commentPostCubit,
  })  : _postRepo = postRepo,
        _authBloc = authBloc,
        _commentPostCubit = commentPostCubit,
        super(
          CommentState.initial(),
        ) {
    on<FetchCommentEvent>(_onFetchComment);
    on<UpdateCommentsEvent>(_onUpdateComments);
    on<AddCommentEvent>(_onAddComment);
    on<DeleteCommentEvent>(_onDeleteComment);
  }

  @override
  Future<void> close() {
    _commentSubscription?.cancel();
    return super.close();
  }

  void _onFetchComment(
    FetchCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    emit(state.copyWith(status: CommentStatus.loading));
    try {
      _commentSubscription?.cancel();
      _commentSubscription =
          await _postRepo.getPostCommentsStream(postId: event.post.id!).listen(
        (comments) async {
          final allComments = await Future.wait(comments);
          add(UpdateCommentsEvent(commentList: allComments));
        },
      );

      emit(state.copyWith(postModel: event.post, status: CommentStatus.loaded));
    } on FirebaseException catch (e) {
      emit(state.copyWith(
        status: CommentStatus.error,
        failure:
            Failure(message: e.message ?? 'cannot update comments! try again'),
      ));
      print("Firebase Error: ${e.message}");
    } catch (e) {
      emit(state.copyWith(
        status: CommentStatus.error,
        failure: const Failure(
            message: "We were unable to load this post's comments"),
      ));
      print("Something Unknown Error: $e");
    }
  }

  void _onUpdateComments(
    UpdateCommentsEvent event,
    Emitter<CommentState> emit,
  ) async {
    emit(state.copyWith(status: CommentStatus.loading));
    try {
      emit(state.copyWith(
          commentList: event.commentList, status: CommentStatus.loaded));
    } on FirebaseException catch (e) {
      emit(state.copyWith(
        status: CommentStatus.error,
        failure:
            Failure(message: e.message ?? 'cannot update comments! try again'),
      ));
      print("Firebase Error: ${e.message}");
    } catch (e) {
      emit(state.copyWith(
        status: CommentStatus.error,
        failure: const Failure(message: 'cannot update comments! try again'),
      ));
      print("Something Unknown Error: $e");
    }
  }

  void _onAddComment(
    AddCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    emit(state.copyWith(status: CommentStatus.submitting));
    try {
      if (state.post == null) {
        emit(state.copyWith(
          status: CommentStatus.error,
          failure: const Failure(message: 'cannot post comment! try again'),
        ));
        return;
      }

      final author = _authBloc.state.user;
      final comment = CommentModel(
        postId: state.post!.id!,
        content: event.content,
        author: author,
        dateTime: DateTime.now(),
      );

      _postRepo.createComment(post: state.post!, comment: comment);
      _commentPostCubit.createComment(post: state.post!, comment: comment);

      emit(state.copyWith(
        status: CommentStatus.loaded,
      ));
    } on FirebaseException catch (e) {
      emit(state.copyWith(
        status: CommentStatus.error,
        failure:
            Failure(message: e.message ?? 'cannot post comment! try again'),
      ));
      print("Firebase Error: ${e.message}");
    } catch (e) {
      emit(state.copyWith(
        status: CommentStatus.error,
        failure: const Failure(message: 'cannot post comment! try again'),
      ));
      print("Something Unknown Error: $e");
    }
  }

  void _onDeleteComment(
      DeleteCommentEvent event,
      Emitter<CommentState> emit,
      ) async {
    emit(state.copyWith(status: CommentStatus.submitting));
    try {
      if (state.post == null) {
        emit(state.copyWith(
          status: CommentStatus.error,
          failure: const Failure(message: 'cannot delete comment! try again'),
        ));
        return;
      }

      _postRepo.deleteComment(post: state.post!, comment: event.comment);
      final commentsLength = state.commentList.length;

      var previousComment = null;
      if (commentsLength == 1) {
        previousComment = null;
      } else if (state.commentList.indexOf(event.comment) == commentsLength - 1) {
        previousComment = state.commentList[commentsLength - 2];
      } else {
        previousComment = state.commentList[commentsLength - 1];
      }

      _commentPostCubit.deleteComment(post: state.post!, comment: event.comment, previousComment: previousComment);

      emit(state.copyWith(
        status: CommentStatus.loaded,
      ));
    } on FirebaseException catch (e) {
      emit(state.copyWith(
        status: CommentStatus.error,
        failure:
        Failure(message: e.message ?? 'cannot delete comment! try again'),
      ));
      print("Firebase Error: ${e.message}");
    } catch (e) {
      emit(state.copyWith(
        status: CommentStatus.error,
        failure: const Failure(message: 'cannot detele comment! try again'),
      ));
      print("Something Unknown Error: $e");
    }
  }
}
