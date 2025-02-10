// ignore_for_file: file_names

import 'package:flutter/material.dart';

// Custom Imports
import 'package:readify/features/auth_screens/forget_password_screen.dart';
import 'package:readify/features/auth_screens/register_screen.dart';

class AuthController {
  // Navigate to Register Screen
  GestureTapCallback navigateToRegisterScreen(BuildContext context) {
    return () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        ),
      );
    };
  }

  // Navigate to forget password
  GestureTapCallback navigateToForgotPasswordScreen(BuildContext context) {
    return () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ForgetPasswordScreen(),
        ),
      );
    };
  }
}
