import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:megaspice/blocs/blocs.dart';
import 'package:megaspice/cubit/comment_post_cubit/comment_post_cubit.dart';
import 'package:megaspice/extensions/datetime_extensions.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/repositories/repositories.dart';
import 'package:megaspice/screens/home/screens/navbar/cubit/NavBarCubit.dart';
import 'package:megaspice/widgets/widgets.dart';

import '../screens.dart';
import 'bloc/comment_bloc.dart';

class CommentScreenArgs {
  final PostModel post;

  CommentScreenArgs({required this.post});
}

class CommentScreen extends StatefulWidget {
  static const String routeName = "/comments";

  static Route route({required CommentScreenArgs args}) {
    return MaterialPageRoute(
      settings:
          RouteSettings(name: CommentScreen.routeName, arguments: args.post),
      builder: (_) => BlocProvider<CommentBloc>(
        create: (context) => CommentBloc(
          postRepo: context.read<PostRepo>(),
          authBloc: context.read<AuthBloc>(),
          commentPostCubit: context.read<CommentPostCubit>(),
        )..add(
            FetchCommentEvent(post: args.post),
          ),
        child: CommentScreen(),
      ),
    );
  }

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentBloc, CommentState>(
        listener: (context, commentState) {
      if (commentState.status == CommentStatus.error) {
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(message: commentState.failure.message),
        );
      }
    }, builder: (context, commentState) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Comments'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              context.read<NavBarCubit>().showNavBar();
              Navigator.of(context).pop();
            },
          ),
        ),
        bottomSheet: _buildCommentBottomSheet(context, commentState),
        body: _buildComments(context, commentState),
      );
    });
  }

  Widget _buildComments(BuildContext context, CommentState state) {
    return state.status == CommentStatus.loading
        ? Center(child: const CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 20, right: 10),
            itemCount: state.commentList.length,
            itemBuilder: (context, index) {
              final comment = state.commentList[index];
              return ListTile(
                leading: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    ProfileScreen.routeName,
                    arguments: ProfileScreenArgs(userId: comment!.author.uid),
                  ),
                  child: UserProfileImage(
                    radius: 22,
                    profileImageURL: comment!.author.photo!,
                  ),
                ),
                title: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: comment.author.username,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: " "),
                      TextSpan(
                        text: comment.content,
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  '${comment.dateTime.timeAgoExt()}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: comment.author.uid == context.read<AuthBloc>().state.user.uid
                             ||
                        state.post!.author.uid == context.read<AuthBloc>().state.user.uid
                    ? IconButton(
                        constraints: BoxConstraints(maxHeight: 18),
                        padding: new EdgeInsets.all(0),
                        iconSize: 18,
                        icon: Icon(
                          FontAwesomeIcons.trash,
                          color: state.status == CommentStatus.submitting
                              ? Colors.blueAccent
                              : Colors.black87,
                        ),
                        onPressed: () {
                          context.read<CommentBloc>().add(
                                DeleteCommentEvent(
                                    post: state.post!,
                                    comment: comment,
                                    previousComment: index == 0
                                        ? null
                                        : state.commentList.last),
                              );
                        },
                      )
                    : null,
              );
            },
          );
  }

  Widget _buildCommentBottomSheet(BuildContext context, CommentState state) {
    return context.read<AuthBloc>().state.status == AuthStatus.unauthenticated
        ? SizedBox()
        : Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.status == CommentStatus.submitting)
                const LinearProgressIndicator(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UserProfileImage(
                      radius: 18,
                      profileImageURL:
                          context.read<AuthBloc>().state.user.photo,
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        child: TextField(
                            enabled: state.status != CommentStatus.submitting,
                            controller: _commentController,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              label: Text(
                                'Write a comment...',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal),
                              ),
                              labelStyle: TextStyle(color: Colors.grey[500]),
                              filled: true,
                              fillColor: Color.fromARGB(255, 226, 226, 226),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                    width: 5.0, color: Colors.transparent),
                              ),
                            )),
                      ),
                    ),
                    IconButton(
                      constraints: BoxConstraints(maxHeight: 36),
                      padding: new EdgeInsets.all(0.0),
                      iconSize: 28,
                      icon: Icon(
                        FontAwesomeIcons.comment,
                        color: state.status == CommentStatus.submitting
                            ? Colors.blueAccent
                            : Colors.black87,
                      ),
                      onPressed: state.status == CommentStatus.submitting ||
                              context.read<AuthBloc>().state.status ==
                                  AuthStatus.unauthenticated
                          ? null
                          : () {
                              final commentText =
                                  _commentController.text.trim();
                              if (commentText.isNotEmpty) {
                                context.read<CommentBloc>().add(
                                      AddCommentEvent(content: commentText),
                                    );
                              }
                              _commentController.clear();
                            },
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
