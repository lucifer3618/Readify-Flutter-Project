import 'package:flutter/material.dart';

// Custom Imports
import 'package:readify/features/auth_screens/login_screen.dart';
import 'package:readify/features/onboarding_screen/data/onbording_screen_data.dart';
import 'package:readify/features/onboarding_screen/model/onboarding_screen_model.dart';
import 'package:readify/features/onboarding_screen/widgets/onboarding_screen_layout.dart';
import 'package:readify/features/onboarding_screen/widgets/onbording_bottom_navbar.dart';
import 'package:readify/features/onboarding_screen/widgets/page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Currently selected index that reflect the page
  int _selectedIndex = 0;

  // Page Controller
  final PageController _pageController = PageController();

  // Onbording Screen Data
  final List<OnboardingScreenModel> onbordingScreensData =
      OnboradingScreenData().onbordingScreensData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: PageView.builder(
              itemCount: onbordingScreensData.length,
              controller: _pageController,
              onPageChanged: (value) {
                setState(() {
                  _selectedIndex = value;
                });
              },
              itemBuilder: (context, index) {
                OnboardingScreenModel onbordingScreen =
                    onbordingScreensData[index];
                return OnboardingScreenLayout(
                  title: onbordingScreen.title,
                  description: onbordingScreen.description,
                  image: onbordingScreen.image,
                );
              },
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          PageIndicator(
            itemCount: onbordingScreensData.length,
            selectedItem: _selectedIndex,
          ),
        ],
      ),
      bottomNavigationBar: OnbordingBottomNavbar(
        isLastPage: _selectedIndex == onbordingScreensData.length - 1,
        onPress: () {
          setState(() {
            _pageController.nextPage(
                duration: Durations.medium2, curve: Curves.easeInOut);
          });
        },
        onPressEnd: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
