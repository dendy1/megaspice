import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/repositories/repositories.dart';
import 'package:megaspice/screens/home/screens/profile/profile_bloc/profile_bloc.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UserRepo _userRepo;
  final StorageRepo _storageRepo;
  final ProfileBloc _profileBloc;

  EditProfileCubit({
    required UserRepo userRepo,
    required StorageRepo storageRepo,
    required ProfileBloc profileBloc,
  })  : _userRepo = userRepo,
        _storageRepo = storageRepo,
        _profileBloc = profileBloc,
        super(EditProfileState.initial()) {
    final user = _profileBloc.state.user;
    emit(
      state.copyWith(
        name: user.displayName,
        gender: user.gender,
        dateOfBirth: user.dateOfBirth,
      ),
    );
  }

  void profileImageChanged(File image) {
    emit(
      state.copyWith(profileImage: image, status: EditProfileStatus.initial),
    );
  }

  void nameChanged(String name) {
    emit(
      state.copyWith(name: name, status: EditProfileStatus.initial),
    );
  }

  void genderChanged(String gender) {
    emit(
      state.copyWith(gender: gender, status: EditProfileStatus.initial),
    );
  }

  void dateOfBirthChanged(DateTime dateOfBirth) {
    emit(
      state.copyWith(
          dateOfBirth: dateOfBirth, status: EditProfileStatus.initial),
    );
  }

  void disableUser(User user) {
    _userRepo.updateUser(user: user.copyWith(disabled: true));
  }
  
  void submit() async {
    emit(state.copyWith(status: EditProfileStatus.submitting));
    try {
      //  getting existing user
      final user = _profileBloc.state.user;

      //getting existing profile image url
      var profileImageUrl = user.photo;

      //if user choose photo in edit profile page
      if (state.profileImage != null) {
        profileImageUrl = await _storageRepo.uploadProfileImageAndGiveUrl(
            url: profileImageUrl, image: state.profileImage!);
      }

      //  updated user with current edit in edit page
      final updatedUser = user.copyWith(
        name: state.name,
        gender: state.gender,
        dateOfBirth: state.dateOfBirth,
        photo: profileImageUrl,
      );

      //  storing updated info to firebase
      await _userRepo.updateUser(user: updatedUser);

      //  updating the profile page with updated data
      _profileBloc.add(ProfileLoadEvent(userId: user.uid));

      //success and removing progress
      emit(state.copyWith(status: EditProfileStatus.success));
    } catch (err) {
      emit(
        state.copyWith(
          status: EditProfileStatus.error,
          failure: Failure(message: "unable to update profile: " + err.toString()),
        ),
      );
    }
  }
}
