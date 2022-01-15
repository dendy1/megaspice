import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserProfileImage extends StatelessWidget {
  final double radius;
  final String? profileImageURL;
  final File? profileImage;

  const UserProfileImage({
    required this.radius,
    required this.profileImageURL,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? backgroundImage = null;
    if (this.profileImage != null) {
      backgroundImage = FileImage(this.profileImage!);
    } else if (this.profileImageURL != null && this.profileImageURL!.isNotEmpty) {
      backgroundImage = CachedNetworkImageProvider(this.profileImageURL!);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: backgroundImage,
      child: _noProfileIcon(),
    );
  }

  Icon? _noProfileIcon() {
    if (profileImage == null && (profileImageURL == null || profileImageURL!.isEmpty))
      return Icon(
        Icons.account_circle,
        color: Colors.grey[400],
        size: radius * 2,
      );
    return null;
  }
}
