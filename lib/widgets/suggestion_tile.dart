import 'package:flutter/material.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/screens/home/screens/screens.dart';
import 'package:megaspice/widgets/widgets.dart';

class SuggestionTile extends StatelessWidget {
  final User user;

  const SuggestionTile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        ProfileScreen.routeName,
        arguments: ProfileScreenArgs(userId: user.uid),
      ),
      child: Container(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                UserProfileImage(
                  radius: 46,
                  profileImageURL: user.photo,
                ),
                const SizedBox(height: 8),
                Text(
                  user.username ?? "unknown",
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
