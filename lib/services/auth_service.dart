import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/services/helper_function.dart';

class AuthService {
  // Create auth Instance
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User getCurrentUser() {
    return _firebaseAuth.currentUser!;
  }

  // Create user
  Future registerUserWithEmailAndPassword(String email, String password, String username) async {
    try {
      final credential =
          await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = credential.user;
      if (user != null) {
        await DatabaseService().savingUserData(user.uid, username, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Set displayname
  Future setCurrrentUserDisplayname(String username) async {
    log(username);
    await _firebaseAuth.currentUser!.updateDisplayName(username);
  }

  // Signin with email and password
  Future signInUserWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign in with google
  Future signInWithGoogle() async {
    // Interective Sign in dialog
    GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // check if it return a user
    if (gUser == null) {
      return null;
    }

    // Obtain auth data from the request
    GoogleSignInAuthentication gAuth = await gUser.authentication;

    // Create Credential for user
    AuthCredential credential =
        GoogleAuthProvider.credential(idToken: gAuth.idToken, accessToken: gAuth.accessToken);

    UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

    if (userCredential.additionalUserInfo!.isNewUser) {
      log("new");
    }

    return userCredential.user;
  }

  // Sign out user
  Future signOut() async {
    try {
      await HelperFunction.setUserLoginStatus(false);
      await HelperFunction.setUserEmail("");
      await HelperFunction.setUserName("");
      await _firebaseAuth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      return null;
    }
  }

  // Reset Password
  Future sendPasswordResetMail(String email) async {
    try {
      QuerySnapshot snapshot = await DatabaseService().gettingUserDataByEmail(email);
      if (snapshot.docs.isNotEmpty) {
        await _firebaseAuth.sendPasswordResetEmail(email: email);
        return true;
      } else {
        return "Email not found!";
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
