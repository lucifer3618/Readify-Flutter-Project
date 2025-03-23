import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/utils/app_style.dart';

class RequestNotificationCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> senderData;
  const RequestNotificationCard({super.key, required this.data, required this.senderData});

  @override
  State<RequestNotificationCard> createState() => _RequestNotificationCardState();
}

class _RequestNotificationCardState extends State<RequestNotificationCard> {
  late String lastNotificationTime;

  @override
  Widget build(BuildContext context) {
    lastNotificationTime =
        (DateFormat("yMd").format((widget.data['timestamp'] as Timestamp).toDate()) ==
                DateFormat("yMd").format(DateTime.now()))
            ? DateFormat("HH:mm").format((widget.data['timestamp'] as Timestamp).toDate())
            : DateFormat("MM-dd").format((widget.data['timestamp'] as Timestamp).toDate());
    return _requestCard(Icons.request_page, Colors.purple);
  }

  Widget _requestCard(IconData icon, Color iconBgColor) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
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
                  Text(
                    "${widget.data['title']}",
                    style: GoogleFonts.aDLaMDisplay(fontWeight: FontWeight.w500, fontSize: 17),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: widget.senderData["username"],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: " has send you a ${widget.data['title']}.")
                    ]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    lastNotificationTime,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            DatabaseService().deleteNotificationFromId(widget.data["id"]);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Accept"),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            DatabaseService().deleteNotificationFromId(widget.data["id"]);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            foregroundColor: AppStyle.errorColor,
                            surfaceTintColor: AppStyle.errorColor,
                          ),
                          child: const Text("Reject"),
                        ),
                      ),
                    ],
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
                DatabaseService().deleteNotificationFromId(widget.data["id"]);
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
                        "Delete this Request",
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
