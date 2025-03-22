import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:readify/features/auth_screens/login_screen.dart';
import 'package:readify/features/profile_screen/added_book_screen.dart';
import 'package:readify/features/profile_screen/bookmarks_screen.dart';
import 'package:readify/features/profile_screen/edit_profile_screen.dart';
import 'package:readify/features/profile_screen/widgets/currently_reading_book_card.dart';
import 'package:readify/features/profile_screen/widgets/option_item.dart';
import 'package:readify/features/profile_screen/widgets/profile_status_card.dart';
import 'package:readify/providers/user_provider.dart';
import 'package:readify/services/auth_service.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/shared/widgets/profile_image_widget.dart';
import 'package:readify/shared/widgets/widgets.dart';
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
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ));
              },
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
          padding: AppStyle.pagePadding.add(const EdgeInsets.only(top: 15)),
          child: Column(
            children: [
              const SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    ProfileImageWidget(
                      width: 100,
                      height: 100,
                      borderColor: Colors.white,
                      borderWidth: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Text(
                    userProvider.user?.displayName ?? "Guest",
                    style: GoogleFonts.firaSans(fontSize: 20, fontWeight: FontWeight.bold),
                  );
                },
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
                      count: "0",
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
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddedBooksScreen(),
                            ));
                      },
                    ),
                    OptionItem(
                      icon: FluentIcons.location_add_16_filled,
                      text: "Update My Location",
                      onTap: () {
                        Widgets.showScanningPopup(context);
                      },
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
