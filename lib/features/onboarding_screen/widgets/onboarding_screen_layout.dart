import 'package:flutter/material.dart';

// Custom Imports
import 'package:readify/utils/app_style.dart';

class OnboardingScreenLayout extends StatefulWidget {
  final String title, description, image;
  const OnboardingScreenLayout(
      {super.key,
      required this.title,
      required this.description,
      required this.image});

  @override
  State<OnboardingScreenLayout> createState() => _OnboardingScreenLayoutState();
}

class _OnboardingScreenLayoutState extends State<OnboardingScreenLayout> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(
      AssetImage(widget.image),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              widget.image,
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.4,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            widget.title,
            style: AppStyle.headlineTwo,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.description,
              style: AppStyle.normalFadedSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
