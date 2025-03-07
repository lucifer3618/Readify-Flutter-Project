import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  // Keys
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";

  // Getters
  static Future<bool?> getUserLoginStatus() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(userLoggedInKey);
  }

  // Setters
  static Future<bool?> setUserLoginStatus(bool status) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setBool(userLoggedInKey, status);
  }

  static Future<bool?> setUserName(String name) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setString(userNameKey, name);
  }

  static Future<bool?> setUserEmail(String email) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setString(userEmailKey, email);
  }

  // Generate random book id
  String generateRandomBookId(int length) {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();

    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Generate random book id
  String generateRandomProfileImageId(int length) {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();

    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Generate random notification id
  String generateNotificationId(int length) {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();

    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
    );
    if (image != null) {
      File localFile = File(image.path);
      return localFile;
    } else {
      return null;
    }
  }
}
