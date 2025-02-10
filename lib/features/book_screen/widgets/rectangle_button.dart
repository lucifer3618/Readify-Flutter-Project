import 'package:flutter/material.dart';

class RectangleButton extends StatelessWidget {
  final Color bgColor;
  final String text;
  final IconData? icon;
  const RectangleButton({super.key, this.icon, required this.bgColor, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: (icon == null)
          ? Text(
              text,
              style:
                  const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 35,
                  weight: 10,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  text,
                  style: const TextStyle(
                      fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                )
              ],
            ),
    );
  }
}
