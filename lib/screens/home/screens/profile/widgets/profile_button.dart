import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/blocs/blocs.dart';
import 'package:megaspice/screens/home/screens/profile/profile_bloc/profile_bloc.dart';
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
        ? _buildButton('Edit Profile', () {
            Navigator.of(context).pushNamed(
              EditProfileScreen.routeName,
              arguments: EditProfileScreenArgs(context: context),
            );
          })
        : _buildButton(isFollowing ? 'Unfollow' : 'Follow', () {
            isFollowing
                ? context.read<ProfileBloc>().add(
                      ProfileUnfollowUserEvent(),
                    )
                : context.read<ProfileBloc>().add(
                      ProfileFollowUserEvent(),
                    );
            ;
          });
  }

  Widget _buildButton(String text, VoidCallback onPressedCallback) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        child: Text(text, style: TextStyle(fontSize: 14)),
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
        onPressed: () => onPressedCallback(),
      ),
    );
  }
}
