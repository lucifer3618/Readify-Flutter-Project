import 'package:flutter/material.dart';

// Custom Imports
import 'package:readify/utils/app_style.dart';

class PasswordInputField extends StatefulWidget {
  final Color color;
  final String hint;
  final bool hasError;
  final String? Function(String? value)? validator;
  final TextEditingController? controller;
  const PasswordInputField(
      {super.key,
      required this.color,
      required this.hint,
      this.controller,
      required this.hasError,
      this.validator});

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.color, width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: !widget.hasError
            ? AppStyle.primaryColor.withValues(alpha: 0.15)
            : AppStyle.errorColor.withValues(alpha: 0.15),
        labelText: widget.hint,
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
          child: AnimatedSwitcher(
            duration: Durations.medium1,
            switchInCurve: Curves.bounceIn,
            child: Icon(
              _isObscure ? Icons.visibility : Icons.visibility_off,
              key: ValueKey<bool>(_isObscure),
            ),
          ),
        ),
      ),
      obscureText: _isObscure,
    );
  }
}
