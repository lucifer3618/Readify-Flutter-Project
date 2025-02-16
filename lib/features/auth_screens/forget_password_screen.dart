import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:readify/features/auth_screens/login_screen.dart';
import 'package:readify/services/auth_service.dart';
import 'package:readify/shared/widgets/text_input_field.dart';
import 'package:readify/shared/widgets/widgets.dart';

// Custom Imports
import 'package:readify/utils/app_media.dart';
import 'package:readify/utils/app_style.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(
      const AssetImage(AppMedia.forgotPasswordImage),
      context,
    );
  }

  // Form key
  final _formKey = GlobalKey<FormState>();

  // State bools
  bool _hasError = false;
  bool _isLoading = false;

  // Input controllers
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: AppStyle.pagePadding,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(AppMedia.forgotPasswordImage),
                          const Text(
                            "Forgot",
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "Password?",
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Please enter your valid email address and check your inbox for a password reset link. Follow the instructions to regain access to your account.",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextInputField(
                            color: AppStyle.primaryColor,
                            hint: "Email",
                            controller: _emailController,
                            hasError: _hasError,
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
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Widgets.customElevatedButton(
                                  "Get reset link",
                                  AppStyle.primaryColor,
                                  () {
                                    resetPassword(_emailController.text);
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void resetPassword(String email) async {
    if (_formKey.currentState!.validate() == false) {
      setState(() {
        _hasError = true;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
      await AuthService().sendPasswordResetMail(email).then(
        (value) {
          if (mounted) {
            if (value == true) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (Route<dynamic> route) => false,
              );
              Widgets.showSnackbar(
                context,
                Colors.green,
                "Reset link has send to the email.",
                ContentType.success,
              );
            } else {
              Widgets.showSnackbar(
                context,
                Colors.red,
                value,
                ContentType.failure,
              );
            }
            setState(() {
              _isLoading = false;
            });
          }
        },
      );
    }
  }
}
