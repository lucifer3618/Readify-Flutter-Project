import 'dart:developer';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readify/services/notification_service.dart';
import 'package:readify/shared/widgets/bookmark_button.dart';
import 'package:readify/features/book_screen/widgets/rectangle_button.dart';
import 'package:readify/features/message_screen/chat_page.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/services/web_services.dart';
import 'package:readify/utils/app_style.dart';

class BookScreen extends StatefulWidget {
  final String bookId, bookName, author, imagePath, currentOwnerId;

  const BookScreen({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.author,
    required this.imagePath,
    required this.currentOwnerId,
  });

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  // ignore: prefer_collection_literals
  Map<String, dynamic> reciverData = Map();

  void fetchBookData() async {
    try {
      final Map<String, dynamic> data = await DatabaseService().getUserById(widget.currentOwnerId);
      setState(() {
        reciverData = data;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    fetchBookData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.bookScreenBackground,
      appBar: AppBar(
        title: const Text(
          "Book Details",
          style: TextStyle(fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: AppStyle.bookScreenBackground,
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.share_outlined,
              color: AppStyle.subtextColor,
            ),
          )
        ],
      ),
      body: _bookPage(),
    );
  }

  // Book Page
  Widget _bookPage() {
    return FutureBuilder(
      future: WebService().getBookData(widget.bookName, widget.author),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: SizedBox(width: 60, height: 60, child: CircularProgressIndicator()));
        } else {
          return Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.imagePath,
                      placeholder: (context, url) => const SizedBox(
                          width: 50, height: 50, child: Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      width: 170,
                    ),
                  ),
                ),
              ),
              _bookData(snapshot)
            ],
          );
        }
      },
    );
  }

  // Book Data Widget
  Widget _bookData(AsyncSnapshot<Map<String, dynamic>?> snapshot) {
    if (snapshot.hasData) {
      return Expanded(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withValues(alpha: 0.2),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Available",
                                style: TextStyle(fontSize: 20, color: AppStyle.primaryColor),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              AutoSizeText(
                                widget.bookName,
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.author,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 184, 183, 183)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        BookmarkButton(
                          bookId: widget.bookId,
                          iconSize: 30,
                          selected: AppStyle.bookScreenButtonBG,
                          nonSelected: AppStyle.primaryColor,
                          padding: 5,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(181, 237, 238, 242),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                "Year",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: AppStyle.subtextColor),
                              ),
                              Text(
                                (snapshot.data!["volumeInfo"]["publishedDate"]) != null
                                    ? snapshot.data!["volumeInfo"]["publishedDate"]
                                        .toString()
                                        .split("-")[0]
                                    : "",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                            child: VerticalDivider(
                              thickness: 1,
                              color: AppStyle.subtextColor,
                            ),
                          ),
                          Column(
                            children: [
                              const Text(
                                "No of pages",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: AppStyle.subtextColor),
                              ),
                              Text(
                                "${snapshot.data!["volumeInfo"]["pageCount"] ?? "0"} pages",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                            child: VerticalDivider(
                              thickness: 1,
                              color: AppStyle.subtextColor,
                            ),
                          ),
                          Column(
                            children: [
                              const Text(
                                "Language",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: AppStyle.subtextColor),
                              ),
                              Text(
                                (snapshot.data!["volumeInfo"]["language"] != null)
                                    ? snapshot.data!["volumeInfo"]["language"]
                                        .toString()
                                        .toUpperCase()
                                    : "",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          snapshot.data!["volumeInfo"]["description"] ?? "",
                          textAlign: TextAlign.justify,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  (FirebaseAuth.instance.currentUser!.uid == widget.currentOwnerId)
                      ? const Row(
                          children: [
                            Expanded(
                              child: RectangleButton(
                                  icon: Icons.check,
                                  bgColor: AppStyle.bookScreenButtonBG,
                                  text: "Mark as Finished"),
                            ),
                          ],
                        )
                      : _buttonRow(reciverData)
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buttonRow(Map<String, dynamic> reiciverData) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      reiciverData: reiciverData,
                    ),
                  ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyle.bookScreenButtonBG,
              padding: const EdgeInsets.symmetric(
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const AutoSizeText(
              "Contact Owner",
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        // TODO: Button should change desgin when click. & Implement the request fucntion in phase 2
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final String reciverToken =
                  await DatabaseService().getFCMToken(widget.currentOwnerId);
              NotificationService().sendNotification(
                reciverToken,
                "Request for ${widget.bookName}.",
                "has requested ${widget.bookName}.",
                "request",
                widget.currentOwnerId,
                widget.bookId,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyle.steelBlue,
              padding: const EdgeInsets.symmetric(
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const AutoSizeText(
              "Request Exchange",
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }
}
