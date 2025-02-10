import 'package:readify/features/onboarding_screen/model/onboarding_screen_model.dart';
import 'package:readify/utils/app_media.dart';

class OnboradingScreenData {
  final List<OnboardingScreenModel> onbordingScreensData = [
    // Screen One
    const OnboardingScreenModel(
      title: "Discover and Share Books",
      description:
          "Explore a diverse collection of books shared by other readers in your community. Share books you've finished reading and make them available for others to enjoy!",
      image: AppMedia.shareImage,
    ),

    // Screen Two
    const OnboardingScreenModel(
      title: "Seamless Exchanges",
      description:
          "Connect with fellow book lovers for easy book exchanges. Send and manage exchange requests right from the app, ensuring a smooth sharing experience.",
      image: AppMedia.seemlessExchange,
    ),

    // Screen Three
    const OnboardingScreenModel(
        title: "Ready to Begin?",
        description:
            "Bookmark favorites, track your exchanges, and connect with like-minded readers. Join a growing community where books bring people together.",
        image: AppMedia.familyImage)
  ];
}
