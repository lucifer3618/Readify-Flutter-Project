import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readify/services/database_service.dart';

class ProfileImageWidget extends StatelessWidget {
  final double width, height, borderWidth;
  final Color borderColor;
  const ProfileImageWidget(
      {super.key,
      required this.width,
      required this.height,
      required this.borderColor,
      required this.borderWidth});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService().getUserStreamById(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: width - 5,
            height: height - 5,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: borderColor, width: borderWidth)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                imageUrl: snapshot.data!["profile_img"]["profile_url"] != ""
                    ? snapshot.data!["profile_img"]["profile_url"]
                    : "https://ui-avatars.com/api/?background=random&name=${FirebaseAuth.instance.currentUser!.displayName!.split(" ")[0]}",
                placeholder: (context, url) => SizedBox(
                    width: width - 5,
                    height: height - 5,
                    child: const Center(child: CircularProgressIndicator())),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                width: width + 10,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      },
    );
  }
}
