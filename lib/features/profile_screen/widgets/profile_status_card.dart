import 'package:flutter/material.dart';

class ProfileStatusCard extends StatelessWidget {
  final String imagePath, count, text;
  const ProfileStatusCard(
      {super.key, required this.imagePath, required this.count, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100), color: Colors.grey.withValues(alpha: 0.1)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              imagePath,
              width: 25,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          text,
          style: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontSize: 14),
        )
      ],
    );
  }
}
