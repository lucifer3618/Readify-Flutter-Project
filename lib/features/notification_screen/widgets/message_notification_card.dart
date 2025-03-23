import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:readify/features/book_screen/book_screen.dart';
import 'package:readify/features/message_screen/chat_page.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/utils/app_style.dart';

class MessageNotificationCard extends StatefulWidget {
  final Map<String, dynamic> notificationData;
  final Map<String, dynamic> senderData;
  final Map<String, dynamic>? bookData;
  const MessageNotificationCard(
      {super.key,
      required this.senderData,
      required this.notificationData,
      required this.bookData});

  @override
  State<MessageNotificationCard> createState() => _MessageNotificationCardState();
}

class _MessageNotificationCardState extends State<MessageNotificationCard> {
  late String lastNotificationTime;

  @override
  Widget build(BuildContext context) {
    lastNotificationTime = (DateFormat("yMd")
                .format((widget.notificationData['timestamp'] as Timestamp).toDate()) ==
            DateFormat("yMd").format(DateTime.now()))
        ? DateFormat("HH:mm").format((widget.notificationData['timestamp'] as Timestamp).toDate())
        : DateFormat("MM-dd").format((widget.notificationData['timestamp'] as Timestamp).toDate());
    if (widget.notificationData["type"] == "chat") {
      return widget.notificationData["isViewed"]
          ? _notificationCard(Colors.white, FluentIcons.eye_16_filled, AppStyle.sunsetOrange)
          : _notificationCard(AppStyle.primaryColor.withValues(alpha: 0.1),
              Icons.notifications_active, AppStyle.primaryColor);
    } else if (widget.notificationData["type"] == "book") {
      return widget.notificationData["isViewed"]
          ? _bookNotificationCard(Colors.white, FluentIcons.eye_16_filled,
              AppStyle.midnightBueColor.withValues(alpha: 0.8))
          : _bookNotificationCard(AppStyle.primaryColor.withValues(alpha: 0.1),
              Icons.notifications_active, AppStyle.primaryColor);
    } else {
      return Container();
    }
  }

  // Notification card
  Widget _notificationCard(Color bgColor, IconData icon, Color iconBgColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(reiciverData: widget.senderData),
          ),
        );
        DatabaseService().setNotificationStatusById(widget.notificationData["id"]);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: bgColor),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                CachedNetworkImage(
                  imageUrl:
                      "https://ui-avatars.com/api/?background=random&name=${widget.senderData["username"].split(" ")[0]}",
                  placeholder: (context, url) => const SizedBox(
                      width: 40, height: 40, child: Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  width: 60,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(100), color: iconBgColor),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ]),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: "${widget.notificationData['title']}",
                          style: GoogleFonts.aDLaMDisplay(fontWeight: FontWeight.w300),
                        ),
                        const TextSpan(text: " has send you a new message.")
                      ]),
                    ),
                    Text(
                      widget.notificationData["message"],
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppStyle.subtextColor),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      lastNotificationTime,
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _bottomSheet(),
                icon: const Icon(FluentIcons.more_vertical_16_filled),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Book Notification card
  Widget _bookNotificationCard(Color bgColor, IconData icon, Color iconBgColor) {
    return GestureDetector(
      onTap: () {
        if (widget.bookData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookScreen(
                  bookId: widget.bookData!["id"],
                  bookName: widget.bookData!["name"],
                  author: widget.bookData!["author"],
                  imagePath: widget.bookData!["image_path"],
                  currentOwnerId: widget.bookData!["currentOwnerId"]),
            ),
          );
          DatabaseService().setNotificationStatusById(widget.notificationData["id"]);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: bgColor),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                CachedNetworkImage(
                  imageUrl:
                      "https://avatar.iran.liara.run/public?username=${widget.senderData["username"].split(" ")[0]}",
                  placeholder: (context, url) => const SizedBox(
                      width: 40, height: 40, child: Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  width: 60,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(100), color: iconBgColor),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ]),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: "${widget.notificationData['title']}",
                          style: GoogleFonts.aDLaMDisplay(fontWeight: FontWeight.w300),
                        ),
                        TextSpan(
                            text: " ${widget.bookData!["name"]} has neen added to the network.")
                      ]),
                    ),
                    Text(
                      widget.notificationData["message"],
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppStyle.subtextColor),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      lastNotificationTime,
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: widget.bookData?["image_path"] != null
                    ? CachedNetworkImage(
                        imageUrl: widget.bookData?["image_path"],
                        placeholder: (context, url) => const SizedBox(
                            width: 40,
                            height: 40,
                            child: Center(child: CircularProgressIndicator())),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        width: 60,
                      )
                    : const SizedBox(
                        width: 60,
                        height: 60,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
              ),
              GestureDetector(
                onTap: () => _bottomSheet(),
                child: const Icon(FluentIcons.more_vertical_16_filled),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom model sheet
  Future<dynamic> _bottomSheet() {
    return showModalBottomSheet(
      elevation: 0,
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                DatabaseService().deleteNotificationFromId(widget.notificationData["id"]);
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  backgroundColor: Colors.white),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        FluentIcons.delete_28_regular,
                        size: 30,
                        color: AppStyle.errorColor,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Delete this Notification",
                        style: TextStyle(
                            color: AppStyle.errorColor, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Icon(
                    FluentIcons.ios_arrow_rtl_24_filled,
                    color: AppStyle.errorColor,
                    size: 25,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
