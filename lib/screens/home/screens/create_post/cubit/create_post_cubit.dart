import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/blocs/blocs.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/repositories/repositories.dart';
import 'package:megaspice/screens/home/screens/profile/profile_bloc/profile_bloc.dart';

part 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  final PostRepo _postRepo;
  final StorageRepo _storageRepo;
  final AuthBloc _authBloc;

  CreatePostCubit({
    required PostRepo postRepo,
    required StorageRepo storageRepo,
    required AuthBloc authBloc,
  })  : _postRepo = postRepo,
        _storageRepo = storageRepo,
        _authBloc = authBloc,
        super(CreatePostState.initial()) {}

  void postImageChanged(File file) {
    emit(state.copyWith(postImage: file, status: CreatePostStatus.initial));
  }

  void captionChanged(String caption) {
    emit(state.copyWith(caption: caption, status: CreatePostStatus.initial));
  }

  void reset() {
    emit(CreatePostState.initial());
  }

  void submit() async {
    emit(state.copyWith(status: CreatePostStatus.submitting));
    try {
      final author = User.empty.copyWith(id: _authBloc.state.user.uid);
      final postImageUrl =
          await _storageRepo.uploadPostImageAndGiveUrl(image: state.postImage!);
      final caption = state.caption;
      final post = PostModel(
        caption: caption,
        imageUrl: postImageUrl,
        author: author,
        likes: 0,
        comments: 0,
        dateTime: DateTime.now(),
      );

      _postRepo.createPost(post: post);
      emit(state.copyWith(status: CreatePostStatus.success));
    } catch (err) {
      emit(
        state.copyWith(
          status: CreatePostStatus.failure,
          failure: const Failure(message: "unable to create your post"),
        ),
      );
    }
  }
}
