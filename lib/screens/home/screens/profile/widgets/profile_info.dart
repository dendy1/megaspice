import 'package:flutter/material.dart';
import 'package:megaspice/extensions/datetime_extensions.dart';

class ProfileInfo extends StatelessWidget {
  final String fullName;
  final String gender;
  final DateTime? dateOfBirth;

  const ProfileInfo({
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fullName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          gender,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          dateOfBirth == null ? "" : '${dateOfBirth!.calculateAgeExt()} years old',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
