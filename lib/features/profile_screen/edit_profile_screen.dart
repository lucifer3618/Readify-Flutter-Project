import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:readify/providers/user_provider.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/services/helper_function.dart';
import 'package:readify/shared/widgets/widgets.dart';
import 'package:readify/utils/app_style.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? image;

  final _nameController =
      TextEditingController(text: FirebaseAuth.instance.currentUser!.displayName);
  final _mobileController = TextEditingController();

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

  final _formKey = GlobalKey<FormState>();
  final _focusScopeNode = FocusScopeNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        forceMaterialTransparency: true,
      ),
      body: GestureDetector(
        onTap: () {
          _focusScopeNode.unfocus();
        },
        child: FocusScope(
          node: _focusScopeNode,
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  AppStyle.pagePadding.add(const EdgeInsets.only(top: 25, left: 10, right: 10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    } else {
                                      return SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            useOldImageOnUrlChange: true,
                                            imageUrl: snapshot.data!["profile_img"]
                                                        ["profile_url"] !=
                                                    ""
                                                ? snapshot.data!["profile_img"]["profile_url"]
                                                : "https://ui-avatars.com/api/?background=random&name=${FirebaseAuth.instance.currentUser!.displayName.toString().split(" ")[0]}",
                                            placeholder: (context, url) => const SizedBox(
                                                width: 50,
                                                height: 50,
                                                child: Center(child: CircularProgressIndicator())),
                                            errorWidget: (context, url, error) =>
                                                const Icon(Icons.error),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    }
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
                    height: 25,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.all(20),
                            labelText: "Full name",
                            hintText: "Full name",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "This field is required!";
                            } else if (value.length < 8) {
                              return "Fullname should be at least 8 characters.";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.all(20),
                              labelText: "Email",
                              enabled: false,
                              disabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10))),
                          initialValue: FirebaseAuth.instance.currentUser!.email,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: _mobileController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.all(20),
                            labelText: "Mobile",
                            hintText: "07X-XXXXXXX",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "This field is required!";
                            } else if (!RegExp(r'^(?:\+94|0)(7[01245678]|[1-9])[0-9]{7}$')
                                .hasMatch(value)) {
                              return "Invalid mobile number format!";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        const Text(
                          "Update and continue",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () => _updateProfileData(context),
                          style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(15),
                              backgroundColor: AppStyle.primaryColor),
                          child: const Icon(
                            FluentIcons.arrow_right_28_filled,
                            size: 25,
                            weight: 10,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: AppStyle.pagePadding.add(const EdgeInsets.symmetric(horizontal: 10)),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
                height: 70,
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                )),
          ),
        ]),
      ),
    );
  }

  _updateProfileData(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      await Provider.of<UserProvider>(context, listen: false)
          .updateDisplayName(_nameController.text);
      bool isUpdated =
          DatabaseService().updateUserData(_nameController.text, _mobileController.text);
      if (mounted) {
        if (isUpdated) {
          // ignore: use_build_context_synchronously
          Widgets.showSnackbar(context, AppStyle.primaryColor, "Profile Data Updated Successfully!",
              ContentType.success);
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        } else {
          Widgets.showSnackbar(
            // ignore: use_build_context_synchronously
            context,
            AppStyle.primaryColor,
            "Profile Data Updated Faild!",
            ContentType.failure,
          );
        }
      }
    }
  }
}
