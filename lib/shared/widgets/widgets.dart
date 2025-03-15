import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:readify/services/database_service.dart';
import 'package:toastification/toastification.dart';

class Widgets {
  static void showSnackbar(BuildContext context, Color color, String message, ContentType type) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      dismissDirection: DismissDirection.horizontal,
      content: AwesomeSnackbarContent(
        title: type == ContentType.success ? "Success!" : "Oops!",
        message: message,
        contentType: type,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static ElevatedButton customElevatedButton(String text, Color color, Function() onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  static void showScanningPopup(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/gif/gps-scanning.json',
                  width: 250,
                  height: 250,
                  repeat: true,
                ),
                const Text(
                  "Scanning...",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Calibrating the location data. Please wait...",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    await DatabaseService().updateUserLocation();
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();

    toastification.show(
      // ignore: use_build_context_synchronously
      context: context,
      title: const Text('Location Updated.'),
      autoCloseDuration: const Duration(milliseconds: 1500),
      type: ToastificationType.success,
      style: ToastificationStyle.simple,
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      borderRadius: BorderRadius.circular(30),
      animationBuilder: (context, animation, alignment, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }
}
