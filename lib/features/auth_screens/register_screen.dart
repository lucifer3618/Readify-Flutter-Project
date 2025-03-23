import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Generate unique form key.
  final _formKey = GlobalKey<FormState>();

  // Check for error states in the form
  bool _hasError = false;

  // InputControllers
  final TextEditingController _usernameController = TextEditingController();
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
                              "Register Here",
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
                              "Welcome to Readify! Let’s get you started.",
                              style: AppStyle.headlinethree,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            TextInputField(
                              color: AppStyle.primaryColor,
                              hint: "Username",
                              controller: _usernameController,
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
                              hasError: _hasError,
                            ),
                            const SizedBox(
                              height: 20,
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
                              height: 40,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _registerUser(
                                  _emailController.text,
                                  _passwordController.text,
                                  _usernameController.text,
                                );
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
                                "Register",
                                style: TextStyle(color: Colors.white, fontSize: 22),
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
                                onTap: () => _signUpWithGoogle(),
                                buttonText: "Sign Up with Google",
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

  // Register using email and password
  void _registerUser(String email, String password, String username) async {
    if (_formKey.currentState!.validate() == true) {
      setState(() {
        _isLoading = true; // Show loading
      });

      try {
        // Attempt to register the user
        bool result =
            await AuthService().registerUserWithEmailAndPassword(email, password, username);

        if (result == true) {
          // Set login status and user details
          await HelperFunction.setUserLoginStatus(true);
          await HelperFunction.setUserName(username);
          await HelperFunction.setUserEmail(email);
          await AuthService().setCurrrentUserDisplayname(username);

          if (mounted) {
            // Navigate to HomeScreen if successful
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
            NotificationService.updateFCMToken();
            DatabaseService().updateUserLocation();
          }
        } else {
          // Show error message if registration fails
          if (mounted) {
            Widgets.showSnackbar(context, Colors.red, result.toString(), ContentType.failure);
          }
        }
      } catch (e) {
        // Handle any errors (e.g., FirebaseAuthException) and show a snackbar
        if (mounted) {
          Widgets.showSnackbar(context, Colors.red, "An error occurred: $e", ContentType.failure);
        }
      } finally {
        // Ensure loading is stopped regardless of success or failure
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _hasError = true;
      });
    }
  }

  // Sign up with google
  Future _signUpWithGoogle() async {
    User? user = await AuthService().signInWithGoogle();
    setState(() {
      _isLoading = true;
    });

    if (user == null && mounted) {
      Widgets.showSnackbar(
          context, Colors.red, "Failed to Sign up with Google!", ContentType.failure);
    } else {
      await DatabaseService().savingUserData(user!.uid, user.displayName!, user.email!);
    }

    QuerySnapshot snapshot =
        await DatabaseService().savingUserData(user!.uid, user.displayName!, user.email!);
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
      _isLoading = false;
    });
  }
}
