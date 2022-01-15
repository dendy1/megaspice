import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final String fullName;
  final String gender;
  final String dateOfBirth;

  const ProfileInfo({
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          gender,
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          dateOfBirth,
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
        const Divider(),
      ],
    );
  }
}
