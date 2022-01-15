import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:megaspice/extensions/datetime_extensions.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/screens/home/screens/profile/profile_screen.dart';
import 'package:megaspice/screens/home/screens/screens.dart';
import 'package:megaspice/widgets/post_dialog.dart';
import 'package:megaspice/widgets/user_profile_image.dart';

class PostView extends StatelessWidget {
  final PostModel post;
  final bool isLiked;
  final VoidCallback onLike;

  const PostView({
    Key? key,
    required this.isLiked,
    required this.post,
    required this.onLike,
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
        // _buildComments(context),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.pushNamed(context, PostScreen.routeName,
            arguments: PostScreenArgs(
              post: post,
              isLiked: isLiked,
            ));
      },
      onDoubleTap: onLike,
      child: CachedNetworkImage(
        height: MediaQuery.of(context).size.height / 2.25,
        width: double.infinity,
        imageUrl: post.imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            onPressed: onLike,
            icon: isLiked
                ? const Icon(Icons.favorite, color: Colors.red)
                : const Icon(Icons.favorite_outline),
            iconSize: 30.0,
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              CommentScreen.routeName,
              arguments: CommentScreenArgs(post: post),
            ),
            icon: Icon(FontAwesomeIcons.comment),
            iconSize: 30.0,
          )
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
          const SizedBox(height: 4),
          Text(
            '${post.dateTime.timeAgoExt()}',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComments(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "another_user",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 5.0,
          ),
          Text(
            "Nice picture!",
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}

class PostDial extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;
  late bool isLiked;

  PostDial({
    Key? key,
    required this.isLiked,
    required this.post,
    required this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Stack(
      children: [
        CachedNetworkImage(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          imageUrl: post.imageUrl,
          fit: BoxFit.cover,
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(0.0),
            child: IconButton(
              onPressed: () {
                this.isLiked = !this.isLiked;
                onLike();
              },
              icon: this.isLiked
                  ? const Icon(Icons.favorite, color: Colors.red)
                  : const Icon(Icons.favorite_outline),
              iconSize: 60.0,
            ),
          ),
        )
      ],
    ));
  }
}
