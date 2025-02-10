import 'package:flutter/material.dart';

// Custom Imports
import 'package:readify/utils/app_style.dart';

class TextInputField extends StatelessWidget {
  final Color color;
  final String hint;
  final bool hasError;
  final double radius;
  final TextEditingController? controller;
  final String? Function(String? value)? validator;

  const TextInputField({
    super.key,
    required this.color,
    required this.hint,
    this.controller,
    this.validator,
    required this.hasError,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(radius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 3),
          borderRadius: BorderRadius.circular(radius),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppStyle.errorColor, width: 2),
        ),
        filled: true,
        fillColor: !hasError
            ? AppStyle.primaryColor.withValues(alpha: 0.15)
            : AppStyle.errorColor.withValues(alpha: 0.15),
        labelText: hint,
      ),
    );
  }
}
