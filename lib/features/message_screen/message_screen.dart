import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:readify/features/message_screen/chat_page.dart';
import 'package:readify/features/message_screen/widgets/user_tile.dart';
import 'package:readify/services/chat_service.dart';
import 'package:readify/shared/widgets/empty_data_page.dart';
import 'package:readify/utils/app_style.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  // Instantiate ChatService
  final ChatService _chatService = ChatService();

  // Search Text Controller
  final TextEditingController _searchController = TextEditingController();

  // Search Text
  String searchText = "";
  bool isOpened = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, kToolbarHeight),
          child: _animatedSearchBar()),
      body: _buildUserList(),
    );
  }

  // Animated Search bar
  Widget _animatedSearchBar() {
    return AppBar(
      title: AnimatedContainer(
        duration: const Duration(milliseconds: 4000),
        curve: Curves.easeInOut,
        child: isOpened
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: AppStyle.primaryColor, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: AppStyle.primaryColor, width: 2),
                          ),
                          hintText: "Search"),
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Card(
                    shape: const CircleBorder(),
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            isOpened = false;
                            _searchController.clear();
                          });
                        },
                        icon: const Icon(Icons.close)),
                  )
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 46,
                  ),
                  const Text(
                    "Messages",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isOpened = true;
                      });
                    },
                    icon: const Icon(
                      FluentIcons.search_16_filled,
                      size: 30,
                    ),
                  ),
                ],
              ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      forceMaterialTransparency: true,
    );
  }

  // Chat list
  Widget _buildUserList() {
    // Screen width
    final double screenWdith = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: AppStyle.pagePadding.add(const EdgeInsets.only(top: 10)),
            child: StreamBuilder(
              stream: isOpened
                  ? _chatService.searchChatUserStream(searchText)
                  : _chatService.getChatUserStream(),
              builder: (context, snapshot) {
                // Check for errors
                if (snapshot.hasError) {
                  return const Text("Erro");
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: SizedBox(width: 70, height: 70, child: CircularProgressIndicator()));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const EmptyDataPage(
                    imgPath: "assets/images/empty-inbox.png",
                    title: "Oops! No Messages",
                    description:
                        "Your inbox is currently empty. Start a conversation to fill it up!. Stay Connected!",
                    wdithFactor: 0.8,
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(snapshot.data![index]["uid"]),
                        confirmDismiss: (DismissDirection direction) async {
                          return await _dismissConfirmationAlert();
                        },
                        direction: DismissDirection.endToStart,
                        dismissThresholds: {DismissDirection.endToStart: 0.5},
                        onDismissed: (direction) {
                          ChatService().deleteChat(snapshot.data![index]["uid"], context);
                        },
                        background: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20), color: AppStyle.errorColor),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: screenWdith * 0.05),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: _userCard(context, snapshot.data![index]),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // User card
  Widget _userCard(BuildContext constxt, Map<String, dynamic> data) {
    String senderId = FirebaseAuth.instance.currentUser!.uid;
    if (senderId != data["uid"]) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: UserTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  reiciverData: data,
                ),
              ),
            );
          },
          text: data["username"],
          reciverId: data["uid"],
        ),
      );
    } else {
      return Container();
    }
  }

  // Confirm dismiss alert
  Future<bool> _dismissConfirmationAlert() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you wish to delete this item?"),
          actions: <Widget>[
            ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyle.errorColor.withValues(alpha: 0.8)),
                child: const Text(
                  "DELETE",
                  style: TextStyle(color: Colors.white),
                )),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.primaryColor.withValues(alpha: 0.8)),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
