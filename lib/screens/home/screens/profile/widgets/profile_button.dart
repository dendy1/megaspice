import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/blocs/blocs.dart';
import 'package:megaspice/screens/home/screens/screens.dart';

class ProfileButton extends StatelessWidget {
  final bool? isCurrentUser;
  final bool isFollowing;

  const ProfileButton({
    required this.isCurrentUser,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    if (isCurrentUser == null) {
      return SizedBox();
    }
    return isCurrentUser!
        ? TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () => Navigator.of(context).pushNamed(
              EditProfileScreen.routeName,
              arguments: EditProfileScreenArgs(context: context),
            ),
            child: const Text(
              'Edit Profile',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          )
        : TextButton(
            style: TextButton.styleFrom(
              backgroundColor: isFollowing
                  ? Colors.grey[300]
                  : Theme.of(context).primaryColor,
            ),
            onPressed: () {
              isFollowing
                  ? context.read<ProfileBloc>().add(
                        ProfileUnfollowUserEvent(),
                      )
                  : context.read<ProfileBloc>().add(
                        ProfileFollowUserEvent(),
                      );
            },
            child: Text(
              isFollowing ? 'Unfollow' : 'Follow',
              style: TextStyle(
                  fontSize: 16,
                  color: isFollowing ? Colors.black : Colors.white),
            ),
          );
  }
}
