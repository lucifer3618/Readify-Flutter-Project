import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:readify/features/book_screen/book_screen.dart';
import 'package:readify/features/home_screen/add_book_form.dart';
import 'package:readify/features/home_screen/widgets/book_tile.dart';
import 'package:readify/features/home_screen/widgets/books_category_tile.dart';
import 'package:readify/features/home_screen/widgets/nearby_book_card.dart';
import 'package:readify/features/home_screen/widgets/search_bar.dart';
import 'package:readify/features/message_screen/message_screen.dart';
import 'package:readify/features/profile_screen/profile_screen.dart';
import 'package:readify/features/notification_screen/notification_screen.dart';
import 'package:readify/providers/user_provider.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/shared/widgets/profile_image_widget.dart';
import 'package:readify/utils/app_style.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Pages List
  final List<Widget> _pages = [
    const HomePage(),
    const MessageScreen(),
    const NotificationScreen(),
    const ProfileScreen()
  ];

  // Fucntion to change selected index
  void changeSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: 0.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppStyle.primaryColor.withValues(alpha: 0.3),
              color: AppStyle.sunsetOrange,
              haptic: false,
              onTabChange: (value) {
                changeSelectedIndex(value);
              },
              selectedIndex: _selectedIndex,
              tabs: const <GButton>[
                GButton(
                  icon: FluentIcons.home_16_regular,
                  text: "Home",
                ),
                GButton(
                  icon: FluentIcons.chat_16_regular,
                  text: "Messages",
                ),
                GButton(
                  icon: FluentIcons.alert_16_regular,
                  text: "Notifications",
                ),
                GButton(
                  icon: FluentIcons.person_16_regular,
                  text: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(
      NetworkImage(
          "https://ui-avatars.com/api/?background=random&name=${FirebaseAuth.instance.currentUser!.displayName!.split(' ')[0]}"),
      context,
    );
  }

  // Date formatters
  DateFormat dateFormat = DateFormat("d, MMMM");

  final FocusScopeNode _searchFocusNode = FocusScopeNode();

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size(double.infinity, MediaQuery.of(context).size.height * 0.21),
              child: _appbarSection(now)),
          body: SingleChildScrollView(
            child: Padding(
              padding: AppStyle.pagePadding.add(const EdgeInsets.only(top: 5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Books Near You",
                        style: GoogleFonts.aDLaMDisplay(fontSize: 24),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: _nearbyBookSection(),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Reacently viewed",
                        style: GoogleFonts.aDLaMDisplay(fontSize: 24),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: _recentlyViewedBooks(),
                      ),
                      Text(
                        "Explore our categories",
                        style: GoogleFonts.aDLaMDisplay(fontSize: 24),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const BooksCategoryTile(),
                    ],
                  )
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              showModalBottomSheet<void>(
                context: context,
                builder: (context) => const AddBookForm(),
                elevation: 1,
                showDragHandle: true,
                isDismissible: true,
                enableDrag: false,
                isScrollControlled: true,
                sheetAnimationStyle: AnimationStyle(duration: const Duration(milliseconds: 300)),
                backgroundColor: Colors.white,
              );
            },
            backgroundColor: AppStyle.primaryColor,
            child: const Icon(
              Icons.add,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Appbarsection
  Widget _appbarSection(DateTime now) {
    return Padding(
      padding: AppStyle.pagePadding.add(const EdgeInsets.only(top: 20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        return AutoSizeText(
                          "Hello, ${userProvider.user?.displayName?.split(" ")[0] ?? "Guest"} !",
                          style: GoogleFonts.aDLaMDisplay(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    dateFormat.format(now),
                    style: GoogleFonts.merriweatherSans(fontSize: 18, color: Colors.grey),
                  )
                ],
              ),
              const ProfileImageWidget(
                width: 55,
                height: 55,
                borderColor: AppStyle.sunsetOrange,
                borderWidth: 3,
              )
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          CustomSearchBar(
            searchFocusNode: _searchFocusNode,
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  // Recently viewed books
  Widget _recentlyViewedBooks() {
    return StreamBuilder(
      stream: DatabaseService().getRecentlyVisitedBooks(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: Text("No data to display!"),
          );
        } else {
          if (snapshot.data!.isNotEmpty) {
            return Skeletonizer(
              enabled: snapshot.connectionState == ConnectionState.waiting,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: SizedBox(
                      width: 90,
                      child: GestureDetector(
                        onTap: () {
                          _searchFocusNode.dispose();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookScreen(
                                  bookId: snapshot.data![index]["id"],
                                  bookName: snapshot.data![index]["name"],
                                  author: snapshot.data![index]["author"],
                                  imagePath: snapshot.data![index]["image_path"],
                                  currentOwnerId: snapshot.data![index]["ownerId"],
                                ),
                              ));
                        },
                        child: BookTile(
                          name: snapshot.data![index]["name"],
                          category: snapshot.data![index]["category"],
                          imageURL: snapshot.data![index]["image_path"],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: snapshot.data!.length,
              ),
            );
          } else {
            return Center(
              child: Image.asset(
                "assets/images/emptyRecent.jpg",
              ),
            );
          }
        }
      },
    );
  }

  // Book near you section
  Widget _nearbyBookSection() {
    return StreamBuilder(
      stream: DatabaseService().getNearbyBooks(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Loading..."),
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Skeletonizer(
            enabled: snapshot.connectionState == ConnectionState.waiting,
            child: SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookScreen(
                              bookId: snapshot.data![index]["id"],
                              bookName: snapshot.data![index]["name"],
                              author: snapshot.data![index]["author"],
                              imagePath: snapshot.data![index]["image_path"],
                              currentOwnerId: snapshot.data![index]["currentOwnerId"],
                            ),
                          ),
                        );
                        DatabaseService().setRecentlyVisitedBook(
                          snapshot.data![index]["id"],
                          snapshot.data![index]["name"],
                          snapshot.data![index]["author"],
                          snapshot.data![index]["image_path"],
                          snapshot.data![index]["currentOwnerId"],
                          snapshot.data![index]["category"],
                        );
                      },
                      child: NearbyBookCard(bookData: snapshot.data![index]),
                    ),
                  );
                },
                itemCount: snapshot.data!.length,
              ),
            ),
          );
        }
      },
    );
  }
}
