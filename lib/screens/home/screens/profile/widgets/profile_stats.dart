import 'package:flutter/material.dart';


class ProfileStats extends StatelessWidget {
  final bool? isCurrentUser;
  final bool isFollowing;
  final int posts;
  final int following;
  final int followers;

  const ProfileStats({
    required this.isCurrentUser,
    required this.isFollowing,
    required this.posts,
    required this.following,
    required this.followers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Stats(
          label: 'posts',
          count: posts,
        ),
        SizedBox(height: 8,),
        _Stats(
          label: 'followers',
          count: followers,
        ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  final String label;
  final int count;

  const _Stats({
    Key? key,
    required this.label,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.black54),
        )
      ],
    );
  }
}
