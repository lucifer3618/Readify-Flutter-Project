import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:readify/utils/app_style.dart';

class CategoryTile extends StatelessWidget {
  final bool isSelected;
  final String image, name;
  final Function() onTap;
  const CategoryTile(
      {super.key,
      required this.isSelected,
      required this.image,
      required this.name,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: AppStyle.primaryColor, width: 3)
                  : Border.all(style: BorderStyle.none),
              color: AppStyle.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(image),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          AutoSizeText(
            name,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppStyle.primaryColor : AppStyle.subtextColor,
            ),
          ),
        ],
      ),
    );
  }
}
