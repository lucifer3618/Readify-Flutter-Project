import 'package:flutter/material.dart';

// Custom Imports
import 'package:readify/utils/app_style.dart';

class PageIndicator extends StatelessWidget {
  final int selectedItem;
  final int itemCount;
  const PageIndicator(
      {super.key, required this.selectedItem, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: AnimatedContainer(
            duration: Durations.medium1,
            curve: Curves.easeInBack,
            width: selectedItem == index ? 20 : 10,
            height: 10,
            decoration: BoxDecoration(
              color:
                  selectedItem == index ? AppStyle.primaryColor : Colors.grey,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }
}
