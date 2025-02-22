import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Custom Imports
import 'package:readify/features/auth_screens/login_screen.dart';
import 'package:readify/services/location_service.dart';
import 'package:readify/utils/app_style.dart';

class OnbordingBottomNavbar extends StatelessWidget {
  final bool isLastPage;
  final Function() onPress, onPressEnd;
  const OnbordingBottomNavbar(
      {super.key, required this.isLastPage, required this.onPress, required this.onPressEnd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: Durations.medium2,
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: isLastPage
                ? const SizedBox()
                : GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                          fullscreenDialog: true,
                        ),
                      );
                      await LocationService().reqestPermission(context);
                    },
                    child: Text(
                      "Skip",
                      style: AppStyle.normalFaded,
                    ),
                  ),
          ),
          AnimatedSwitcher(
            duration: Durations.medium2,
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: isLastPage
                ? ElevatedButton(
                    onPressed: onPressEnd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyle.primaryColor,
                    ),
                    child: const Text(
                      "Get Started",
                      style: AppStyle.whiteBold,
                    ),
                  )
                : GestureDetector(
                    onTap: onPress,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppStyle.primaryColor,
                      ),
                      child: const Icon(
                        FluentIcons.arrow_right_16_filled,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
