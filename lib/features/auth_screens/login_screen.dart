import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Custom Imports
import 'package:readify/features/auth_screens/auth_screens_controller.dart';
import 'package:readify/features/auth_screens/widgets/login_icon_button.dart';
import 'package:readify/features/home_screen/home_screen.dart';
import 'package:readify/services/auth_service.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/services/helper_function.dart';
import 'package:readify/services/notification_service.dart';
import 'package:readify/shared/widgets/password_input_field.dart';
import 'package:readify/shared/widgets/text_input_field.dart';
import 'package:readify/shared/widgets/widgets.dart';
import 'package:readify/utils/app_style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // AuthControll Instance
  final AuthController _loginScreenController = AuthController();

  // Generate unique form key.
  final _formKey = GlobalKey<FormState>();

  // Check for error states in the form
  bool _hasError = false;

  // InputControllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Check loading bool
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
                strokeWidth: 4,
              ),
            )
          : FocusScope(
              node: FocusScopeNode(),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: AppStyle.pagePadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Login Here",
                              style: GoogleFonts.aDLaMDisplay(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: AppStyle.primaryColor,
                                shadows: [
                                  const Shadow(
                                    blurRadius: 0.4,
                                    color: Colors.grey,
                                    offset: Offset(0, 0),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            const Text(
                              "Welcome back! Please log in to continue.",
                              style: AppStyle.headlinethree,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.07,
                            ),
                            TextInputField(
                              color: AppStyle.primaryColor,
                              hint: "Email",
                              controller: _emailController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "This field is required!";
                                } else if (!RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value)) {
                                  return "Invalid email format!";
                                } else {
                                  setState(() {
                                    _hasError = false;
                                  });
                                  return null;
                                }
                              },
                              hasError: _hasError,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            PasswordInputField(
                              color: AppStyle.primaryColor,
                              hint: "Password",
                              controller: _passwordController,
                              hasError: _hasError,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "This field is required!";
                                } else if (value.length < 8) {
                                  return "Password should be at least 8 characters.";
                                } else {
                                  setState(() {
                                    _hasError = false;
                                  });
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(),
                                GestureDetector(
                                  onTap: _loginScreenController
                                      .navigateToForgotPasswordScreen(context),
                                  child: const Text(
                                    "Forgot your password?",
                                    style: TextStyle(fontSize: 16, color: AppStyle.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (_formKey.currentState!.validate() == false) {
                                    _hasError = true;
                                  } else {
                                    _signInEmailAndPassword(
                                        _emailController.text, _passwordController.text);
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppStyle.primaryColor,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: const Size(
                                  double.infinity,
                                  55,
                                ),
                              ),
                              child: const Text(
                                "Sign in",
                                style: TextStyle(color: Colors.white, fontSize: 22),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            GestureDetector(
                              onTap: _loginScreenController.navigateToRegisterScreen(context),
                              child: const Text(
                                "Create new accout",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            const Text(
                              "or continue with",
                              style: TextStyle(fontSize: 15, color: AppStyle.primaryColor),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            LoginIconButton(
                                onTap: () {
                                  _signInWithGoogle();
                                },
                                buttonText: "Sign in with Google",
                                icon: "assets/images/google.png")
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // Sign in with email and password
  Future _signInEmailAndPassword(String email, String password) async {
    setState(() {
      _isLoading = true;
    });
    await AuthService().signInUserWithEmailAndPassword(email, password).then(
      (value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService().gettingUserData(FirebaseAuth.instance.currentUser!.uid);
          await HelperFunction.setUserLoginStatus(true);
          await HelperFunction.setUserName(snapshot.docs[0]["username"]);
          await HelperFunction.setUserEmail(snapshot.docs[0]["email"]);
          await AuthService().setCurrrentUserDisplayname(snapshot.docs[0]["username"]);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
            NotificationService.updateFCMToken();
            Widgets.showSnackbar(
                context, Colors.green, "Logged in Successfully!", ContentType.success);
            DatabaseService().updateUserLocation();
          }
        } else {
          if (mounted) {
            Widgets.showSnackbar(context, Colors.red, value, ContentType.failure);
          }
        }
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  // Sign in with google
  Future _signInWithGoogle() async {
    User? user = await AuthService().signInWithGoogle();
    setState(() {
      _isLoading = true;
    });

    if (user == null && mounted) {
      Widgets.showSnackbar(
          context, Colors.red, "Failed to Sign in with Google!", ContentType.failure);
    } else {
      await DatabaseService().savingUserData(user!.uid, user.displayName!, user.email!);
    }

    QuerySnapshot snapshot =
        await DatabaseService().gettingUserData(FirebaseAuth.instance.currentUser!.uid);
    await HelperFunction.setUserLoginStatus(true);
    await HelperFunction.setUserEmail(snapshot.docs[0]["email"]);
    await HelperFunction.setUserName(snapshot.docs[0]["username"]);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()), // Replace with your new screen
        (Route<dynamic> route) => false, // This removes all previous routes
      );
      NotificationService.updateFCMToken();
      Widgets.showSnackbar(context, Colors.green, "Successfully logged in!", ContentType.success);
      DatabaseService().updateUserLocation();
    }
    setState(() {
      _isLoading = true;
    });
  }
}
