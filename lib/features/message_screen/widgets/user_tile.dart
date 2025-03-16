import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readify/services/chat_service.dart';
import 'package:readify/utils/app_style.dart';

class UserTile extends StatelessWidget {
  final String text, reciverId, profileImageURL;
  final Function() onTap;
  const UserTile(
      {super.key,
      required this.text,
      required this.onTap,
      required this.reciverId,
      required this.profileImageURL});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        margin: const EdgeInsets.all(4),
        child: Row(
          children: [
            Container(
              width: 55,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(width: 3, color: AppStyle.primaryDark)),
              child: SizedBox(
                width: 55,
                height: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    imageUrl: profileImageURL != ""
                        ? profileImageURL
                        : "https://avatar.iran.liara.run/public?username=${text.split(" ")[0]}",
                    placeholder: (context, url) => const SizedBox(
                        width: 50, height: 50, child: Center(child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    width: 55,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            StreamBuilder(
              stream: ChatService().getLastMessage(reciverId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    // Extract the docs data from snapshot
                    final doc = snapshot.data!.docs[0];
                    if (doc.exists) {
                      // Extract the data from the doc and map
                      var data = doc.data();
                      String lastMessage = data['message'] ?? 'No message';
                      String lastMessageTime = (DateFormat("yMd")
                                  .format((data['timestamp'] as Timestamp).toDate()) ==
                              DateFormat("yMd").format(DateTime.now()))
                          ? DateFormat("HH:mm").format((data['timestamp'] as Timestamp).toDate())
                          : DateFormat("MM-dd").format((data['timestamp'] as Timestamp).toDate());
                      return Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  text,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                                Text(lastMessageTime)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppStyle.subtextColor),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                _unreadCount()
                              ],
                            )
                          ],
                        ),
                      );
                    } else {
                      return Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const Text(
                              "No text messages",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: AppStyle.subtextColor),
                            )
                          ],
                        ),
                      );
                    }
                  } else {
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            text,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const Text(
                            "No text messages",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppStyle.subtextColor),
                          )
                        ],
                      ),
                    );
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }

  // Unread text Widget
  Widget _unreadCount() {
    return StreamBuilder<QuerySnapshot>(
      stream: ChatService().getunreadCount(FirebaseAuth.instance.currentUser!.uid, reciverId),
      builder: (context, snapshot) {
        return snapshot.data == null || snapshot.data!.docs.isEmpty
            ? const SizedBox.shrink()
            : Container(
                padding: EdgeInsets.all(snapshot.data!.docs.length < 10 ? 7 : 5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppStyle.primaryColor,
                ),
                child: Text(
                  snapshot.data!.docs.length > 99 ? "99" : snapshot.data!.docs.length.toString(),
                  style: TextStyle(
                      color: Colors.white, fontSize: snapshot.data!.docs.length < 10 ? 14 : 10),
                ),
              );
      },
    );
  }
}
