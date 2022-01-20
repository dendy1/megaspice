import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:megaspice/extensions/datetime_extensions.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/screens/home/screens/navbar/cubit/NavBarCubit.dart';
import 'package:megaspice/screens/home/screens/profile/profile_screen.dart';
import 'package:megaspice/screens/home/screens/screens.dart';
import 'package:megaspice/screens/home/screens/post/post_screen.dart';
import 'package:megaspice/widgets/user_profile_image.dart';
import 'package:provider/src/provider.dart';

class PostView extends StatelessWidget {
  final PostModel post;
  final CommentModel? lastComment;
  final bool isLiked;
  final int? likes;
  final int? comments;
  final VoidCallback onLike;
  final VoidCallback onPostDelete;

  final bool postAuthor;

  const PostView({
    Key? key,
    required this.isLiked,
    this.likes = 0,
    this.comments = 0,
    required this.post,
    required this.lastComment,
    required this.onLike,
    required this.postAuthor,
    required this.onPostDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      // mainAxisSize: MainAxisSize.min,
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildHeader(context),
        _buildContent(context),
        _buildFooter(context),
        _buildCaption(context),
        _buildComment(context),
        Divider(
          height: 0,
          thickness: 2,
          indent: 0,
          endIndent: 0,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final author = post.author;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName,
            arguments: ProfileScreenArgs(userId: author.uid)),
        child: Row(
          children: <Widget>[
            UserProfileImage(radius: 18, profileImageURL: author.photo),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                author.username ?? "unknown",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 50.0),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    context: context,
                    builder: (context) => _buildPostModal(context));
              },
              icon: Icon(FontAwesomeIcons.ellipsisH),
              iconSize: 24.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<NavBarCubit>().hideNavBar();
        Navigator.pushNamed(context, PostScreen.routeName,
            arguments: PostScreenArgs(
              post: post,
              isLiked: isLiked,
            ));
      },
      onDoubleTap: onLike,
      child: CachedNetworkImage(
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        imageUrl: post.imageUrl,
        fit: BoxFit.fitWidth,
        fadeOutDuration: const Duration(seconds: 1),
        fadeInDuration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              IconButton(
                onPressed: onLike,
                icon: isLiked
                    ? const Icon(Icons.favorite, color: Colors.red)
                    : const Icon(Icons.favorite_outline),
                iconSize: 30.0,
              ),
              Text(
                '${likes == null ? 0 : likes}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '${comments == null ? 0 : comments}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<NavBarCubit>().hideNavBar();
                  Navigator.pushNamed(
                    context,
                    CommentScreen.routeName,
                    arguments: CommentScreenArgs(post: post),
                  );
                },
                icon: Icon(FontAwesomeIcons.comment),
                iconSize: 30.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaption(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text.rich(TextSpan(children: [
            TextSpan(
                text: post.author.username ?? "unknown",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: " "),
            TextSpan(text: post.caption),
          ])),
          const SizedBox(height: 8.0),
          Text(
            '${post.dateTime.timeAgoExt()}',
            style: TextStyle(
                color: Color.fromRGBO(153, 153, 153, 1),
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 12.0),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(BuildContext context) {
    if (lastComment == null) {
      return SizedBox();
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        children: [
          Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    lastComment!.author.username!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    lastComment!.content,
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Widget _buildPostModal(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.solidFlag,
                    size: 20.0,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 24.0,
                  ),
                  Text(
                    " Report",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            thickness: 2,
          ),
          if (postAuthor)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onPostDelete();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.solidTrashAlt,
                      size: 20.0,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 24.0,
                    ),
                    Text(
                      " Delete",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
