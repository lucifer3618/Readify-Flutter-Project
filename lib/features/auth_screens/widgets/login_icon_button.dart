import 'package:flutter/material.dart';

class LoginIconButton extends StatelessWidget {
  final Function() onTap;
  final String icon, buttonText;
  const LoginIconButton(
      {super.key,
      required this.onTap,
      required this.icon,
      required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          elevation: 0.2),
      label: Text(
        buttonText,
        style: const TextStyle(fontSize: 14, color: Colors.black),
      ),
      icon: Image.asset(
        icon,
        width: 25,
      ),
    );
  }
}
