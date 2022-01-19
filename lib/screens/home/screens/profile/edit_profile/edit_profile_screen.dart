import 'dart:io';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:megaspice/blocs/auth_bloc/auth_bloc.dart';
import 'package:megaspice/cubit/cubits.dart';
import 'package:megaspice/helpers/helpers.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/repositories/repositories.dart';
import 'package:megaspice/screens/home/screens/profile/edit_profile/cubit/edit_profile_cubit.dart';
import 'package:megaspice/screens/home/screens/profile/profile_bloc/profile_bloc.dart';
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
                            _buildInput(TextInputType.name, user.displayName!,
                                "Enter your full name", (value) {
                              context
                                  .read<EditProfileCubit>()
                                  .nameChanged(value);
                            },
                                (value) => value!.trim().isEmpty
                                    ? 'Name cannot be empty'
                                    : null),
                            const SizedBox(height: 16),
                            _buildInput(TextInputType.text, user.gender!,
                                "Enter your gender", (value) {
                              context
                                  .read<EditProfileCubit>()
                                  .genderChanged(value);
                            }, null),
                            const SizedBox(height: 28),
                            DateTimePicker(
                                initialValue: user.dateOfBirth.toString(),
                                firstDate: DateTime(1980),
                                lastDate: DateTime(2100),
                                dateMask: "dd-MMM-yyyy",
                                dateLabelText: 'Date of birth',
                                onChanged: (val) => context
                                    .read<EditProfileCubit>()
                                    .dateOfBirthChanged(DateTime.parse(val)),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10.0),
                                  label: Text(
                                    "Enter your date of birth",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Color.fromRGBO(153, 153, 153, 1),
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  labelStyle:
                                      TextStyle(color: Colors.grey[500]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(width: 2.0),
                                  ),
                                )),
                            const SizedBox(height: 48),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                child: Text("Save Profile",
                                    style: TextStyle(fontSize: 14)),
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blueAccent),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  elevation:
                                      MaterialStateProperty.all<double>(4.0),
                                ),
                                onPressed: () => _submitForm(
                                  context,
                                  editProfileState.status ==
                                      EditProfileStatus.submitting,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                child: Text("Delete Profile",
                                    style: TextStyle(fontSize: 14)),
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.redAccent),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  elevation:
                                      MaterialStateProperty.all<double>(4.0),
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ConfirmationDialog(
                                            message:
                                                "This account will be disabled!",
                                            cancelOnPressed: () => Navigator.of(context).pop(),
                                            continueOnPressed: () {
                                              context.read<UserRepo>().disableUser(user: user);
                                              context.read<AuthBloc>().add(AuthDeleteRequestedEvent());
                                              context.read<LikePostCubit>().clearAllLikedPost();
                                            });
                                      });
                                },
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

  Widget _buildInput(
      TextInputType inputType,
      String? initialValue,
      String hintText,
      Function(String) onChanged,
      String? Function(String?)? validator) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      keyboardType: inputType,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        label: Text(
          hintText,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Color.fromRGBO(153, 153, 153, 1),
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        labelStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(width: 2.0),
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
