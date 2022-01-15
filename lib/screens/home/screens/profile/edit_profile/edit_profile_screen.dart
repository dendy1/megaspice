import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:megaspice/blocs/blocs.dart';
import 'package:megaspice/helpers/helpers.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/repositories/repositories.dart';
import 'package:megaspice/screens/home/screens/profile/edit_profile/cubit/edit_profile_cubit.dart';
import 'package:megaspice/widgets/widgets.dart';

class EditProfileScreenArgs {
  final BuildContext context;

  EditProfileScreenArgs({required this.context});
}

class EditProfileScreen extends StatelessWidget {
  static const String routeName = "/edit_profile";

  static Route route({required EditProfileScreenArgs args}) {
    return MaterialPageRoute(
      settings: RouteSettings(name: EditProfileScreen.routeName),
      builder: (_) => BlocProvider<EditProfileCubit>(
        create: (context) => EditProfileCubit(
          userRepo: context.read<UserRepo>(),
          storageRepo: context.read<StorageRepo>(),
          profileBloc: args.context.read<ProfileBloc>(),
        ),
        child: EditProfileScreen(
          user: args.context.read<ProfileBloc>().state.user,
        ),
      ),
    );
  }

  final User user;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  EditProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile'),
        ),
        body: BlocConsumer<EditProfileCubit, EditProfileState>(
          listener: (context, editProfileState) {
            if (editProfileState.status == EditProfileStatus.success) {
              BotToast.showText(text: 'Profile Edited Successfully');
              Navigator.of(context).pop();
              BotToast.closeAllLoading();
            } else if (editProfileState.status == EditProfileStatus.error) {
              BotToast.showText(text: editProfileState.failure.message);
              showDialog(
                context: context,
                builder: (context) => ErrorDialog(
                  message: editProfileState.failure.message,
                ),
              );
            } else if (editProfileState.status ==
                EditProfileStatus.submitting) {
              BotToast.showLoading();
            }
          },
          builder: (context, editProfileState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    if (editProfileState.status == EditProfileStatus.submitting)
                      const LinearProgressIndicator(),
                    SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => _selectProfileImage(context),
                      child: UserProfileImage(
                        radius: 40,
                        profileImage: editProfileState.profileImage,
                        profileImageURL: user.photo,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              initialValue: user.displayName,
                              decoration:
                                  InputDecoration(hintText: 'Full Name'),
                              textCapitalization: TextCapitalization.words,
                              onChanged: (value) {
                                context
                                    .read<EditProfileCubit>()
                                    .nameChanged(value);
                              },
                              validator: (value) => value!.trim().isEmpty
                                  ? 'Name cannot be empty'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: user.gender,
                              decoration: InputDecoration(hintText: 'gender'),
                              onChanged: (value) {
                                context
                                    .read<EditProfileCubit>()
                                    .genderChanged(value);
                              },
                            ),
                            const SizedBox(height: 28),
                            TextButton(
                              style: TextButton.styleFrom(
                                elevation: 1.0,
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              onPressed: () => _submitForm(
                                context,
                                editProfileState.status ==
                                    EditProfileStatus.submitting,
                              ),
                              child: Text(
                                'Update Profile',
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectProfileImage(BuildContext context) async {
    // final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    final pickedFile = await ImageHelper.pickImageFromGallery(
      context: context,
      cropStyle: CropStyle.circle,
      title: "Profile Image",
    );
    if (pickedFile != null) {
      context
          .read<EditProfileCubit>()
          .profileImageChanged(File(pickedFile.path));
    }
  }

  void _submitForm(BuildContext context, bool isSubmitting) {
    if (_formKey.currentState!.validate() && !isSubmitting) {
      context.read<EditProfileCubit>().submit();
    }
  }
}
