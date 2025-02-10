import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  // Colors
  static const Color primaryColor = Color(0xFF009970);
  // Error Color
  static const Color errorColor = Colors.red;
  // Subtext Color
  static const Color subtextColor = Color.fromARGB(255, 124, 124, 124);

  static const Color midnightBueColor = Color(0xFF191970);
  static const Color sendMsgBackground = Color(0xFFCCEBE2);
  static const Color rsvMsgBackground = Color(0xFFF2F2F7);
  static const Color bookScreenBackground = Color(0xFFF5F5F5);
  static const Color bookScreenCardBG = Color(0xFFedeef2);
  static const Color bookScreenButtonBG = Color(0xFFf57b47);
  static const Color steelBlue = Color(0xFF4682b4);
  static const Color sunsetOrange = Color(0xFFFF6F61);
  static const Color primaryDark = Color(0xFF007256);

  // Page Padding
  static const EdgeInsetsGeometry pagePadding = EdgeInsets.symmetric(horizontal: 20);

  // Text Styles
  static TextStyle headlineTwo = GoogleFonts.roboto(
    fontSize: 25,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headlinethree = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle normalFaded = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: const Color.fromARGB(255, 119, 119, 119),
  );
  static const TextStyle normalFadedSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: Color.fromARGB(255, 119, 119, 119),
  );

  static const TextStyle whiteBold = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
