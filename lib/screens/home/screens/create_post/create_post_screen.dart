import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:megaspice/helpers/helpers.dart';
import 'package:megaspice/screens/home/screens/create_post/cubit/create_post_cubit.dart';

class CreatePostScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Create Post"),
      ),
      body: BlocConsumer<CreatePostCubit, CreatePostState>(
        listener: (context, state) {},
        builder: (context, state) {
          return SingleChildScrollView(
            child: GestureDetector(
              onTap: () => _selectPostImage(context),
              child: Column(
                children: [
                  if (state.status == CreatePostStatus.submitting)
                    LinearProgressIndicator(),
                  Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: state.postImage != null
                        ? Container(
                            child: Image.file(
                              state.postImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 120,
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
                            decoration: InputDecoration(hintText: "caption"),
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
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              elevation: 1.0,
                            ),
                            onPressed: () => _submitForm(
                              context,
                              state.postImage!,
                              state.status == CreatePostStatus.submitting,
                            ),
                            child: Text(
                              'Create Post',
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectPostImage(BuildContext context) async {
    final pickedFile = await ImageHelper.pickImageFromCamera(
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
