import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:megaspice/helpers/helpers.dart';
import 'package:megaspice/screens/home/screens/create_post/cubit/create_post_cubit.dart';
import 'package:megaspice/screens/home/screens/navbar/cubit/NavBarCubit.dart';
import 'package:megaspice/screens/home/screens/profile/profile_bloc/profile_bloc.dart';
import 'package:megaspice/widgets/widgets.dart';


class CreatePostScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Create Post"),
      ),
      body: BlocConsumer<CreatePostCubit, CreatePostState>(
        listener: (context, state) {
          if (state.status == CreatePostStatus.success) {
            context.read<NavBarCubit>().updateSelectedItem(NavBarItem.profile);
            context.read<ProfileBloc>()..add(ProfileLoadEvent(
                userId: context.read<ProfileBloc>().state.user.uid));
            Navigator.of(context, rootNavigator: true).pop();
            _formKey.currentState!.reset();
            context.read<CreatePostCubit>().reset();

            BotToast.showText(text: "Post Created Successfully");
          } else if (state.status == CreatePostStatus.submitting) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => LoadingDialog(
                loadingMessage: 'Creating Post',
              ),
            );
          } else if (state.status == CreatePostStatus.failure) {
            Navigator.of(context, rootNavigator: true).pop();
            BotToast.showText(text: state.failure.message);

            showDialog(
              context: context,
              builder: (context) => ErrorDialog(
                message: state.failure.message,
              ),
            );
          }
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () => showDialog(
                context: context,
                builder: (buildContext) =>
                    _buildSelectImageDialog(buildContext, context)),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 150),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (state.status == CreatePostStatus.submitting)
                          LinearProgressIndicator(),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildCaptionInput(context),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 2,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: state.postImage != null
                              ? Container(
                                  child: Image.file(
                                    state.postImage!,
                                    fit: BoxFit.fitWidth,
                                  ),
                                )
                              : const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 120,
                                ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 20.0),
                          child: _buildPostButton(context, state),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaptionInput(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        label: Text(
          'Enter post caption',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Color.fromRGBO(153, 153, 153, 1),
            fontFamily: 'Roboto',
            fontSize: 14,
            letterSpacing: 0,
            fontWeight: FontWeight.normal,
          ),
        ),
        labelStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(width: 2.0),
        ),
      ),
      onChanged: (value) {
        context
            .read<CreatePostCubit>()
            .captionChanged(value);
      },
      validator: (value) {
        return value!.trim().isEmpty
            ? 'Caption cannot be empty'
            : null;
      },
    );
  }

  Widget _buildPostButton(BuildContext context, CreatePostState state) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        child: Text("Publish", style: TextStyle(fontSize: 14)),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor: MaterialStateProperty.all<Color>(
              Color.fromARGB(255, 128, 163, 255)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          elevation: MaterialStateProperty.all<double>(4.0),
        ),
        onPressed: () {
          _submitForm(
            context,
            state.postImage!,
            state.status == CreatePostStatus.submitting,
          );
        },
      ),
    );
  }

  Widget _buildSelectImageDialog(
      BuildContext buildContext, BuildContext mainContext) {
    return AlertDialog(
      content: Container(
        height: MediaQuery.of(buildContext).size.height / 2,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black87),
                  overlayColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(20, 0, 0, 0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.camera,
                      size: 90,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Camera",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                onPressed: () {
                  _selectPostImageFromCamera(mainContext);
                  Navigator.pop(buildContext);
                },
              ),
            ),
            Divider(
              thickness: 2,
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black87),
                    overlayColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(20, 0, 0, 0))),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.image,
                      size: 90,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Gallery",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                onPressed: () {
                  _selectPostImageFromGallery(mainContext);
                  Navigator.pop(buildContext);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _selectPostImageFromCamera(BuildContext context) async {
    final pickedFile = await ImageHelper.pickImageFromCamera(
      context: context,
      cropStyle: CropStyle.rectangle,
      title: 'Post Image',
    );
    if (pickedFile != null) {
      context.read<CreatePostCubit>().postImageChanged(pickedFile);
    }
  }

  void _selectPostImageFromGallery(BuildContext context) async {
    final pickedFile = await ImageHelper.pickImageFromGallery(
      context: context,
      cropStyle: CropStyle.rectangle,
      title: 'Post Image',
    );
    if (pickedFile != null) {
      context.read<CreatePostCubit>().postImageChanged(pickedFile);
    }
  }

  void _submitForm(
      BuildContext context, File postImage, bool isSubmitting) async {
    if (_formKey.currentState!.validate() &&
        postImage != null &&
        !isSubmitting) {
      context.read<CreatePostCubit>().submit();
    }
  }
}
