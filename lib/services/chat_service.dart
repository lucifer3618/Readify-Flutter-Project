import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readify/features/message_screen/models/message.dart';
import 'package:readify/shared/widgets/widgets.dart';
import 'package:readify/utils/app_style.dart';

class ChatService {
  // Get instance of firestore and Auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get all the users
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("users").orderBy("last_message", descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            final user = doc.data();
            return user;
          },
        ).toList();
      },
    );
  }

  // Get Chat user data stream
  Stream<List<Map<String, dynamic>>> getChatUserStream() {
    return _firestore
        .collection("users")
        .where('chatUsers', arrayContains: _firebaseAuth.currentUser!.uid)
        .orderBy("last_message", descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            final user = doc.data();
            return user;
          },
        ).toList();
      },
    );
  }

  // Get Chat user data stream
  Stream<List<Map<String, dynamic>>> searchChatUserStream(String searchText) {
    return _firestore
        .collection("users")
        .where('chatUsers', arrayContains: _firebaseAuth.currentUser!.uid)
        .orderBy("username", descending: true)
        .snapshots()
        .map(
      (snapshot) {
        List<Map<String, dynamic>> users = snapshot.docs.map(
          (doc) {
            final user = doc.data();
            return user;
          },
        ).toList();

        if (searchText.isNotEmpty) {
          return users.where(
            (user) {
              return user['username'].toString().toLowerCase().contains(searchText.toLowerCase());
            },
          ).toList();
        }
        return users;
      },
    );
  }

  // Generate unique chatroom ID
  String generateChatRoomId(String currentUID, String reciverId) {
    List<String> ids = [currentUID, reciverId];
    ids.sort();
    String chatRoomId = ids.join("_");
    return chatRoomId;
  }

  // send message
  Future<void> sendMessage(String reciverId, String message) async {
    // Current user
    User currentUser = _firebaseAuth.currentUser!;

    // Message time stamp
    Timestamp now = Timestamp.now();

    // Create a new message
    Message newMessage = Message(
      senderId: currentUser.uid,
      senderEmail: currentUser.email!,
      reciverId: reciverId,
      message: message,
      timestamp: now,
      viewed: false,
    );

    // Create unique chatroom id for two users
    String chatRoomId = generateChatRoomId(currentUser.uid, reciverId);

    // Add to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());

    await _firestore.collection("users").doc(reciverId).update({
      "chatUsers": FieldValue.arrayUnion([_firebaseAuth.currentUser!.uid]),
    });

    await _firestore.collection("users").doc(_firebaseAuth.currentUser!.uid).update({
      "chatUsers": FieldValue.arrayUnion([reciverId]),
    });
  }

  // Get message
  Stream<QuerySnapshot> getMessage(String senderId, String reciverId) {
    // Create unique chatroom id for two users
    String chatRoomId = generateChatRoomId(senderId, reciverId);

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // Last message recived timestamp
  void lastMessageTimeStamp() async {
    await _firestore.collection("users").doc(_firebaseAuth.currentUser!.uid).update({
      "last_message": Timestamp.now(),
    });
  }

  // get Last Message
  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(String reciverId) {
    // get unique chatroom id of two users
    String chatRoomId = generateChatRoomId(_firebaseAuth.currentUser!.uid, reciverId);
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots();
  }

  // Get unread count
  Stream<QuerySnapshot> getunreadCount(String senderId, String reciverId) {
    // Create unique chatroom id for two users
    String chatRoomId = generateChatRoomId(senderId, reciverId);

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .where("viewed", isEqualTo: false)
        .where("senderId", isEqualTo: reciverId)
        .snapshots();
  }

  // Set messages to read
  Future setMessagesToRead(String senderId, String reciverId) async {
    // Create unique chatroom id for two users
    String chatRoomId = generateChatRoomId(senderId, reciverId);

    QuerySnapshot snapshot = await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .where("viewed", isEqualTo: false)
        .where("senderId", isEqualTo: reciverId)
        .get();
    for (var doc in snapshot.docs) {
      doc.reference.update({
        "viewed": true,
      });
    }
  }

  // Set last read for each chat room
  void setLastRead(String senderId, String reciverId) {
    String chatRoomId = generateChatRoomId(senderId, reciverId);
    _firestore.collection("chat_rooms").doc(chatRoomId).update({
      "last_opened_by": {"userId": senderId, "last_opended_time": Timestamp.now()},
      "last_opened_by_receiver": {"userId": reciverId, "last_opended_time": Timestamp.now()}
    });
  }

  // Delete chat from DB
  void deleteChat(String reciverId, BuildContext context) async {
    try {
      // Create chatroom id
      String chatRoomId = generateChatRoomId(_firebaseAuth.currentUser!.uid, reciverId);

      WriteBatch batch = _firestore.batch();

      // Get chatroom collection and delete each document inside the messages
      DocumentReference chatRoom = _firestore.collection("chat_rooms").doc(chatRoomId);
      QuerySnapshot messages = await chatRoom.collection("messages").get();
      for (QueryDocumentSnapshot doc in messages.docs) {
        batch.delete(doc.reference);
      }
      batch.commit();

      // Remove reciver link
      await _firestore.collection("users").doc(reciverId).update({
        "chatUsers": FieldValue.arrayRemove([_firebaseAuth.currentUser!.uid])
      });

      // Remove current user link
      await _firestore.collection("users").doc(_firebaseAuth.currentUser!.uid).update({
        "chatUsers": FieldValue.arrayRemove([reciverId])
      });

      // ignore: use_build_context_synchronously
      Widgets.showSnackbar(context, AppStyle.primaryColor, "Successfully Deleted!");
    } catch (e) {
      log(e.toString());
    }
  }
}
