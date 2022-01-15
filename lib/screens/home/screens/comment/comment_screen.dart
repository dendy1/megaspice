import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/widgets/widgets.dart';

import '../screens.dart';
import 'bloc/comment_bloc.dart';

class CommentScreenArgs {
  final PostModel post;
  CommentScreenArgs({required this.post});
}

class CommentScreen extends StatefulWidget {
  static const String routeName = "/commentScreen";

  static Route route({required CommentScreenArgs args}) {
    return MaterialPageRoute(
      settings: RouteSettings(
        name: CommentScreen.routeName,
        arguments: args.post,
      ),
      builder: (_) => CommentScreen(),
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
    return BlocConsumer<CommentBloc, CommentState>(listener: (context, commentState) {
      if (commentState.status == CommentStatus.error) {
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(message: commentState.failure.message),
        );
      }
    }, builder: (context, commentState) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Comments'),
          centerTitle: true,
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (commentState.status == CommentStatus.submitting) const LinearProgressIndicator(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: commentState.status != CommentStatus.submitting,
                      controller: _commentController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration.collapsed(hintText: "Write a comment ...."),
                    ),
                  ),
                  IconButton(
                    onPressed: commentState.status == CommentStatus.submitting
                        ? null
                        : () {
                      final commentText = _commentController.text.trim();
                      if (commentText.isNotEmpty) {
                        context.read<CommentBloc>().add(
                          PostCommentsEvent(content: commentText),
                        );
                      }
                      _commentController.clear();
                    },
                    icon: Icon(
                      Icons.send,
                      color: commentState.status == CommentStatus.submitting ? Colors.grey : Colors.blue,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        body: commentState.status == CommentStatus.loading
            ? Center(child: const CircularProgressIndicator())
            : ListView.builder(
          padding: const EdgeInsets.only(bottom: 60),
          itemCount: commentState.commentList.length,
          itemBuilder: (context, index) {
            final comment = commentState.commentList[index];
            return ListTile(
              onTap: () => Navigator.pushNamed(
                context,
                ProfileScreen.routeName,
                arguments: comment!.author.uid,
              ),
              leading: UserProfileImage(
                radius: 22,
                profileImageURL: comment!.author.photo!,
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
                DateFormat.yMd().add_jm().format(comment.dateTime),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
