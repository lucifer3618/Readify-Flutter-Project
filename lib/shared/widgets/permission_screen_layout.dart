import 'package:flutter/material.dart';

// Custom Imports
import 'package:readify/utils/app_style.dart';

class PermissionScreenLayout extends StatefulWidget {
  final String title, description, image;
  final Function() onPressed;
  const PermissionScreenLayout(
      {super.key,
      required this.title,
      required this.description,
      required this.image,
      required this.onPressed});

  @override
  State<PermissionScreenLayout> createState() => _PermissionScreenLayoutState();
}

class _PermissionScreenLayoutState extends State<PermissionScreenLayout> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Permission",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: AppStyle.pagePadding,
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kTextTabBarHeight,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Image.asset(
                        widget.image,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.4,
                      ),
                    ),
                    Text(
                      widget.title,
                      style: AppStyle.headlineTwo,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        widget.description,
                        style: AppStyle.normalFadedSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox.expand(),
                    ElevatedButton(
                      onPressed: widget.onPressed,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: const Size(double.infinity, 60),
                        backgroundColor: AppStyle.primaryColor,
                      ),
                      child: const Text(
                        "Enable Permission",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
