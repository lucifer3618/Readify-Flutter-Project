import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readify/features/auth_screens/login_screen.dart';
import 'package:readify/features/profile_screen/widgets/currently_reading_book_card.dart';
import 'package:readify/features/profile_screen/widgets/option_item.dart';
import 'package:readify/features/profile_screen/widgets/profile_status_card.dart';
import 'package:readify/services/auth_service.dart';
import 'package:readify/utils/app_style.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {},
              child: const Icon(Icons.mode_edit_outline_rounded),
            ),
          )
        ],
        centerTitle: true,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppStyle.pagePadding,
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 100,
                    height: 120,
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://avatar.iran.liara.run/public?username=${FirebaseAuth.instance.currentUser!.displayName.toString().split(" ")[0]}",
                      placeholder: (context, url) => const SizedBox(
                          width: 50, height: 50, child: Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      width: 100,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 37.5,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: AppStyle.primaryColor,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.white, width: 2)),
                        child: const Center(
                          child: Icon(
                            FluentIcons.edit_16_filled,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                FirebaseAuth.instance.currentUser!.displayName!,
                style: GoogleFonts.firaSans(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                FirebaseAuth.instance.currentUser!.email!,
                style: TextStyle(color: Colors.black.withValues(alpha: 0.8)),
              ),
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ProfileStatusCard(
                      count: "10",
                      text: "Added",
                      imagePath: "assets/images/add.webp",
                    ),
                    ProfileStatusCard(
                      count: "22",
                      text: "Exchanged",
                      imagePath: "assets/images/exchange.webp",
                    ),
                    ProfileStatusCard(
                      count: "20",
                      text: "Requests",
                      imagePath: "assets/images/delay.webp",
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              const CurrentlyReadingBookCard(),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.withValues(alpha: 0.07),
                ),
                child: Column(
                  children: [
                    OptionItem(
                      icon: FluentIcons.book_24_filled,
                      text: "Bookmarks",
                      onTap: () {},
                    ),
                    OptionItem(
                      icon: FluentIcons.add_24_filled,
                      text: "Added Books",
                      onTap: () {},
                    ),
                    OptionItem(
                      icon: FluentIcons.branch_request_16_filled,
                      text: "Exchange Requests",
                      onTap: () {},
                    ),
                    OptionItem(
                      icon: FluentIcons.sign_out_24_filled,
                      text: "Sign Out",
                      onTap: () {
                        AuthService().signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
