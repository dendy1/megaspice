import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/blocs/blocs.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/repositories/post/post_repository.dart';

part 'comment_event.dart';

part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final PostRepo _postRepo;
  final AuthBloc _authBloc;
  StreamSubscription<List<Future<CommentModel?>>>? _commentSubscription;

  CommentBloc({
    required PostRepo postRepo,
    required AuthBloc authBloc,
  })  : _postRepo = postRepo,
        _authBloc = authBloc,
        super(
          CommentState.initial(),
        ) {
    on<FetchCommentEvent>(_onFetchComment);
    on<UpdateCommentsEvent>(_onUpdateComments);
    on<PostCommentsEvent>(_onPostComments);
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
          _postRepo.getPostComment(postId: event.post.id!).listen(
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
      emit(state.copyWith(commentList: event.commentList));
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

  void _onPostComments(
    PostCommentsEvent event,
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

      final authorId = User.empty.copyWith(id: _authBloc.state.user.uid);
      final comment = CommentModel(
        postId: state.post!.id!,
        content: event.content,
        author: authorId,
        dateTime: DateTime.now(),
      );
      await _postRepo.createComment(
          postModel: state.post!, commentModel: comment);
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
}
