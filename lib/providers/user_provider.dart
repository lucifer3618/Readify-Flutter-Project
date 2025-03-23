import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  User? _user = FirebaseAuth.instance.currentUser;

  User? get user => _user;

  Future<void> refreshUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User? updatedUser) {
      _user = updatedUser;
      notifyListeners(); // Notify UI to rebuild with updated data
    });
  }

  Future<void> updateDisplayName(String newName) async {
    await FirebaseAuth.instance.currentUser!.updateDisplayName(newName);
    await FirebaseAuth.instance.currentUser!.reload(); // Reload user data
    await refreshUser(); // Refresh data and update UI // Refresh data and update UI
  }
}
