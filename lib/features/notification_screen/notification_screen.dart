import 'package:flutter/material.dart';
import 'package:readify/features/notification_screen/widgets/message_notification_card.dart';
import 'package:readify/features/notification_screen/widgets/request_notification_card.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/shared/widgets/empty_data_page.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Notifications",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                // icon: Icon(FluentIcons.alert_badge_16_filled),
                text: "Notifications",
              ),
              Tab(
                // icon: Icon(FluentIcons.arrow_swap_20_filled),
                text: "Exchanges",
              ),
            ],
          ),
          centerTitle: true,
          forceMaterialTransparency: true,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: TabBarView(
            children: <Widget>[
              _notificationTab(),
              _requestTab(),
            ],
          ),
        ),
      ),
    );
  }

  // Notificaiton Tab Section
  Widget _notificationTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder(
            stream: DatabaseService().getNotificationsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Erro");
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: const Center(
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.735,
                  child: const EmptyDataPage(
                    imgPath: "assets/images/empty-notifications.png",
                    title: "No Notifications Yet?",
                    description:
                        "You're all caught up! When you receive new book exchange requests or important updates, they'll appear here.",
                    wdithFactor: 0.7,
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  physics: const PageScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    // TODO: Fix data fetching expensive operation
                    return FutureBuilder(
                      future: DatabaseService().getNotificationsWithDetails(snapshot.data!),
                      builder: (context, futureSnapshot) {
                        if (snapshot.hasError) {
                          return const Text("Erro");
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: SizedBox(
                                  width: 70, height: 70, child: CircularProgressIndicator()));
                        } else if (futureSnapshot.hasError ||
                            !futureSnapshot.hasData ||
                            futureSnapshot.data == null) {
                          return Container();
                        } else {
                          Map<String, dynamic> senderData =
                              futureSnapshot.data![index]["senderData"];
                          Map<String, dynamic>? bookData = futureSnapshot.data![index]
                                      ["bookData"] !=
                                  null
                              ? Map<String, dynamic>.from(futureSnapshot.data![index]["bookData"])
                              : null;
                          return MessageNotificationCard(
                            notificationData: snapshot.data![index],
                            bookData: bookData,
                            senderData: senderData,
                          );
                        }
                      },
                    );
                  },
                );
              }
            },
          )
        ],
      ),
    );
  }

  Widget _requestTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder(
            stream: DatabaseService().getRequestsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("error");
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: const Center(
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.735,
                  child: const EmptyDataPage(
                    imgPath: "assets/images/no-requests.webp",
                    title: "No Book Requests Yet?",
                    description:
                        "It looks like you haven’t received any book requests yet. Once someone requests a book, you’ll see their details here! ",
                    wdithFactor: 1.5,
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  physics: const PageScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return RequestNotificationCard(
                      data: snapshot.data![index],
                      senderData: snapshot.data![index]['senderData'],
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
