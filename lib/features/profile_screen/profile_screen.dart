import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:readify/features/auth_screens/login_screen.dart';
import 'package:readify/features/profile_screen/bookmarks_screen.dart';
import 'package:readify/features/profile_screen/widgets/currently_reading_book_card.dart';
import 'package:readify/features/profile_screen/widgets/option_item.dart';
import 'package:readify/features/profile_screen/widgets/profile_status_card.dart';
import 'package:readify/services/auth_service.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/services/helper_function.dart';
import 'package:readify/utils/app_style.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? image;

  // Set Imagge
  setImage() async {
    Map<String, dynamic> user =
        await DatabaseService().getUserById(FirebaseAuth.instance.currentUser!.uid);
    String profileImageId = HelperFunction().generateRandomProfileImageId(20);
    await HelperFunction().pickImage().then(
      (value) async {
        if (value != null) {
          setState(() {
            image = value;
          });
          if (image != null) {
            String extention = extension(image!.path);
            await DatabaseService().uploadProfileImageToSupaBase(
              image!,
              "profile_image/$profileImageId$extention",
              user["profile_img"]["file_path"],
            );
            DatabaseService().updateUserProfileImageLink("$profileImageId$extention");
          }
        }
      },
    );
  }

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
              GestureDetector(
                onTap: () {
                  setImage();
                },
                child: SizedBox(
                  width: 100,
                  height: 113,
                  child: Stack(
                    children: [
                      image == null
                          ? FutureBuilder(
                              future: DatabaseService()
                                  .getUserById(FirebaseAuth.instance.currentUser!.uid),
                              builder: (context, snapshot) {
                                return SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      useOldImageOnUrlChange: true,
                                      imageUrl: snapshot.data!["profile_img"]["profile_url"] != ""
                                          ? snapshot.data!["profile_img"]["profile_url"]
                                          : "https://avatar.iran.liara.run/public?username=${FirebaseAuth.instance.currentUser!.displayName.toString().split(" ")[0]}",
                                      placeholder: (context, url) => const SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: Center(child: CircularProgressIndicator())),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.file(
                                image!,
                                fit: BoxFit.cover,
                                height: 100,
                                width: 100,
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 34.5,
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
                      )
                    ],
                  ),
                ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder(
                      stream: DatabaseService().getAddedBooksCount(),
                      builder: (context, snapshot) {
                        return ProfileStatusCard(
                          count: snapshot.data.toString(),
                          text: "Added",
                          imagePath: "assets/images/add.webp",
                        );
                      },
                    ),
                    const ProfileStatusCard(
                      count: "22",
                      text: "Exchanged",
                      imagePath: "assets/images/exchange.webp",
                    ),
                    StreamBuilder(
                        stream: DatabaseService().getBookRequestsCount(),
                        builder: (context, snapshot) {
                          return ProfileStatusCard(
                            count: snapshot.data.toString(),
                            text: "Requests",
                            imagePath: "assets/images/delay.webp",
                          );
                        })
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
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookmarksScreen(),
                            ));
                      },
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
