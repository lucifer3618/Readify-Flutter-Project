import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:readify/services/helper_function.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  // Create FireStore instance
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection("users");

  final CollectionReference _bookCollection = FirebaseFirestore.instance.collection("books");

  final CollectionReference _notificationCollection =
      FirebaseFirestore.instance.collection("notifications");

  // Saving user to database
  Future savingUserData(String uid, String username, String email) async {
    try {
      // Get the snapshot
      DocumentSnapshot doc = await _userCollection.doc(uid).get();

      // Check user Already Exsists
      if (!doc.exists) {
        // Set the new user data if the document exists
        await _userCollection.doc(uid).set({
          "uid": uid,
          "username": username,
          "email": email,
          "profile_img": "",
          "chatUsers": [],
          "fcm_token": "",
        });
      } else {
        // Update the last_login if the document doesn't exist
        await _userCollection.doc(uid).update({
          "last_login": Timestamp.now(),
        });
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  // Getting User data from database
  Future<QuerySnapshot> gettingUserData(String uid) async {
    QuerySnapshot snapshot = await _userCollection.where("uid", isEqualTo: uid).limit(1).get();
    return snapshot;
  }

  // Getting user Data from email
  Future<QuerySnapshot> gettingUserDataByEmail(String email) async {
    QuerySnapshot snapshot = await _userCollection.where("email", isEqualTo: email).limit(1).get();
    return snapshot;
  }

  // Store book in database
  Future savingBookData(String bookId, String bookName, String isbn, String authorName,
      String imagePath, String category) async {
    await _bookCollection.doc(bookId).set({
      "id": bookId,
      "name": bookName,
      "isbn": isbn,
      "author": authorName,
      "image_path": imagePath,
      "category": category,
      "favorited_users": [],
      "ownerId": FirebaseAuth.instance.currentUser!.uid,
      "currentOwnerId": FirebaseAuth.instance.currentUser!.uid,
      "timestamp": Timestamp.now(),
    });
    return true;
  }

  // Upload image to Supabase storage
  Future uploadImageToSupaBase(File image, String path) async {
    await Supabase.instance.client.storage.from('images').upload(path, image);
  }

  // Get spcific user using id
  Future<Map<String, dynamic>> getUserById(String uid) async {
    QuerySnapshot snapshot = await _userCollection.where("uid", isEqualTo: uid).limit(1).get();
    Map<String, dynamic> data = snapshot.docs[0].data() as Map<String, dynamic>;
    return data;
  }

  // Set Recently visited books
  Future<void> setRecentlyVisitedBook(String bookId, String bookName, String author,
      String imagePath, String ownerId, String category) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    var bookReference = _userCollection.doc(currentUserId).collection("visitedBooks").doc(bookId);
    await bookReference.set({
      "id": bookId,
      "name": bookName,
      "author": author,
      "category": category,
      "image_path": imagePath,
      "ownerId": FirebaseAuth.instance.currentUser!.uid,
      "timestamp": Timestamp.now(),
    });
  }

  // Get Recently VisitedBooks
  Stream<List<Map<String, dynamic>>> getRecentlyVisitedBooks() {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return _userCollection.doc(currentUserId).collection("visitedBooks").limit(5).snapshots().map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            return doc.data();
          },
        ).toList();
      },
    );
  }

  // Set FCM Token for user
  void setFMCTocken(String fcmTocken) async {
    DocumentReference docRef = _userCollection.doc(FirebaseAuth.instance.currentUser!.uid);
    docRef.update({
      "fcm_token": fcmTocken,
    });
  }

  // Get FCM token
  Future<String> getFCMToken(String userId) async {
    DocumentSnapshot snapshot = await _userCollection.doc(userId).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    log(data["fcm_token"]);
    return data["fcm_token"];
  }

  // Add notification to a database
  Future addNotification(String reciverId, String title, String message, String type,
      {String bookId = ""}) async {
    String notificationId = HelperFunction().generateNotificationId(10);
    DocumentSnapshot reciverSnapshot = await _userCollection.doc(reciverId).get();
    Map<String, dynamic> reciverData = reciverSnapshot.data() as Map<String, dynamic>;
    String reciverName = reciverData["username"];
    try {
      await _notificationCollection.doc(notificationId).set({
        "id": notificationId,
        "senderId": FirebaseAuth.instance.currentUser!.uid,
        "reciverId": reciverId,
        "reciverName": reciverName,
        "title": title,
        "message": message,
        "type": type,
        "isViewed": false,
        "bookId": bookId,
        "timestamp": Timestamp.now(),
      });
    } catch (e) {
      return "Error: $e";
    }
  }

  // Get notifications stream
  Stream<List<Map<String, dynamic>>> getNotificationsStream() {
    return _notificationCollection
        .where("reciverId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where("type", isNotEqualTo: "request")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            final notification = doc.data() as Map<String, dynamic>;
            return notification;
          },
        ).toList();
      },
    );
  }

  // Get request stream
  Stream getRequestsStream() {
    return _notificationCollection
        .where("reciverId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where("type", isEqualTo: "request")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<String> senderIds = [];

      // Collect all senderIds
      for (var doc in snapshot.docs) {
        final notification = doc.data() as Map<String, dynamic>;
        senderIds.add(notification['senderId']);
      }

      if (senderIds.isNotEmpty) {
        // Fetch all users in a single query
        final userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: senderIds)
            .get();

        final Map<String, Map<String, dynamic>> senderDataMap = {};
        for (var userDoc in userDocs.docs) {
          senderDataMap[userDoc.id] = userDoc.data();
        }

        final requests = snapshot.docs.map((doc) {
          final notification = doc.data() as Map<String, dynamic>;
          final senderId = notification['senderId'];
          notification['senderData'] = senderDataMap[senderId];
          return notification;
        }).toList();

        return requests;
      } else {
        return null;
      }
    });
  }

  // Add to favorite
  void addBookToFavorite(String bookId) {
    _bookCollection.doc(bookId).set(
      {
        'favorited_users': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      },
      SetOptions(merge: true),
    );
  }

  // Remove from favorite
  void removeBookFromFavorite(String bookId) {
    _bookCollection.doc(bookId).set(
      {
        'favorited_users': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      },
      SetOptions(merge: true),
    );
  }

  // Check if the user has book as favorite
  Future<bool> checkIsFavorite(String bookId) async {
    // Get book data from db
    DocumentSnapshot doc = await _bookCollection.doc(bookId).get();
    // Convert book data object into a Map
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List favoritedUsers = data["favorited_users"];
    if (favoritedUsers.contains(FirebaseAuth.instance.currentUser!.uid)) {
      return true;
    } else {
      return false;
    }
  }

  // Delete Notification
  void deleteNotificationFromId(String notificationId) {
    try {
      _notificationCollection.doc(notificationId).delete();
    } catch (e) {
      log(e.toString());
    }
  }

  // Set notification viewd status
  void setNotificationStatusById(String notificationId) {
    try {
      _notificationCollection.doc(notificationId).update({
        "isViewed": true,
      });
    } catch (e) {
      log(e.toString());
    }
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    QuerySnapshot snapshot = await _userCollection
        .where("uid", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    return snapshot.docs.map(
      (doc) {
        return doc.data() as Map<String, dynamic>;
      },
    ).toList();
  }

  // Get book by id
  Future<Map<String, dynamic>> getBookById(String bookId) async {
    return _bookCollection.doc(bookId).get().then(
      (doc) {
        return doc.data() as Map<String, dynamic>;
      },
    );
  }

  // Get book and sender data for all the notification in the stream at once
  Future<List<Map<String, dynamic>>> getNotificationsWithDetails(
      List<Map<String, dynamic>> notifications) async {
    List<Future<Map<String, dynamic>>> futures = notifications.map(
      (notification) async {
        Map<String, dynamic> data = {'notification': notification};

        if (notification["bookId"] != "") {
          var bookData = await _bookCollection.doc(notification["bookId"]).get();
          data["bookData"] = bookData.data();
        }

        var senderData = await _userCollection.doc(notification["senderId"]).get();
        data["senderData"] = senderData.data();

        return data;
      },
    ).toList();
    var results = await Future.wait(futures);
    return results;
  }

  // Get book Stream
  Stream<List<Map<String, dynamic>>> booksStream() {
    return _bookCollection.orderBy("timestamp", descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            return doc.data() as Map<String, dynamic>;
          },
        ).toList();
      },
    );
  }

  // Filtered book stream by category
  Stream<List<Map<String, dynamic>>> filterBooksStreamByCategory(String category) {
    return _bookCollection
        .where("category", isEqualTo: category)
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            return doc.data() as Map<String, dynamic>;
          },
        ).toList();
      },
    );
  }
}
