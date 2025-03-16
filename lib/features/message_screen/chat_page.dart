import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readify/services/auth_service.dart';
import 'package:readify/services/chat_service.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/services/notification_service.dart';
import 'package:readify/shared/widgets/text_input_field.dart';
import 'package:readify/utils/app_style.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> reiciverData;

  const ChatPage({super.key, required this.reiciverData});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Text editing controller
  final TextEditingController _messageController = TextEditingController();

  // Instantiate ChatService on AuthService
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // Scroll controller
  final ScrollController _scrollController = ScrollController();

  // Message text data
  late String msg;

  // Send message function
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // send the message
      msg = _messageController.text;
      // clear controller
      _messageController.clear();
      await _chatService.sendMessage(widget.reiciverData["uid"], msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                imageUrl: widget.reiciverData["profile_img"]["profile_url"] != ""
                    ? widget.reiciverData["profile_img"]["profile_url"]
                    : "https://avatar.iran.liara.run/public?username=${widget.reiciverData["username"].toString().split(" ")[0]}",
                placeholder: (context, url) => const SizedBox(
                    width: 50, height: 50, child: Center(child: CircularProgressIndicator())),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              widget.reiciverData["username"],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            )
          ],
        ),
        leadingWidth: 35,
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: _buildMessageList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
              child: _userInput(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    String sendersId = _authService.getCurrentUser().uid;
    return StreamBuilder(
      stream: _chatService.getMessage(sendersId, widget.reiciverData["uid"]),
      builder: (context, snapshot) {
        // Check for error
        if (snapshot.hasError) {
          return const Text("Erro");
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: SizedBox(width: 60, height: 60, child: CircularProgressIndicator()));
        } else {
          _scrollToEnd();
          ChatService().setMessagesToRead(
              FirebaseAuth.instance.currentUser!.uid, widget.reiciverData["uid"]);
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            controller: _scrollController,
            itemBuilder: (context, index) {
              return _messageLayout(context, snapshot.data!.docs[index]);
            },
          );
        }
      },
    );
  }

  // Message layout
  Widget _messageLayout(BuildContext context, DocumentSnapshot doc) {
    //Convert data to a map
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Check if the current user is the sender
    bool isCurrentUser = (data["senderId"] == _authService.getCurrentUser().uid);

    Timestamp timestamp = data["timestamp"];

    DateTime time = timestamp.toDate();

    DateFormat formatter = DateFormat("HH:mm");

    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Material(
            elevation: 0.5,
            type: MaterialType.card,
            borderRadius: isCurrentUser
                ? const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
            color: isCurrentUser ? AppStyle.sendMsgBackground : AppStyle.rsvMsgBackground,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  Flexible(
                    child: Text(
                      data["message"],
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w100, fontSize: 16),
                      softWrap: true,
                    ),
                  ),
                  Text(
                    formatter.format(time),
                    style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // User input widget
  Widget _userInput() {
    return Row(
      children: [
        Expanded(
          child: TextInputField(
            color: AppStyle.primaryColor,
            hint: "Message",
            hasError: false,
            radius: 20,
            controller: _messageController,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        IconButton(
          onPressed: () async {
            sendMessage();
            _chatService.lastMessageTimeStamp();
            _scrollToEnd();
            final String reciverToken =
                await DatabaseService().getFCMToken(widget.reiciverData["uid"]);
            NotificationService().sendNotification(
                reciverToken,
                FirebaseAuth.instance.currentUser!.displayName!,
                msg,
                "chat",
                widget.reiciverData["uid"],
                "");
          },
          icon: const Icon(Icons.send),
        )
      ],
    );
  }

  // Fucntion to scrool to end of the chat
  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Use a slight delay to ensure new content is rendered
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });
  }
}
