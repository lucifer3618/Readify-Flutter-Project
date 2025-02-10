import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:readify/services/database_service.dart';

class NotificationService {
  // Create firebase messaging instance
  static final FirebaseMessaging _firrebaseMessaging = FirebaseMessaging.instance;

  // Flutter local notifications instance
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Request Notification Permissions
  static Future initNotifications() async {
    await _firrebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      provisional: false,
      sound: true,
      criticalAlert: true,
      carPlay: false,
    );

    // Accuire FCM tokent
    final String? fcmToken = await _firrebaseMessaging.getToken();
    DatabaseService().setFMCTocken(fcmToken!);
  }

  // Update FCM token
  static void updateFCMToken() async {
    final String? fcmToken = await _firrebaseMessaging.getToken();
    DatabaseService().setFMCTocken(fcmToken!);
  }

  // Specify a function to manage tappping on notifications in foreground
  static void onNotificationTapped(NotificationResponse notificationResponse) {}

  // Initialize local notifications for android
  static Future initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        const InitializationSettings(android: initializationSettingsAndroid);

    // Request notifications for android 13 and Above
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: onNotificationTapped,
        onDidReceiveNotificationResponse: onNotificationTapped);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'readify_notifications', // Channel ID
      'Readify Notifications',
      channelDescription: 'Notifications for Readify app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      int.parse(FirebaseAuth.instance.currentUser!.uid), // Notification ID (use unique for updates)
      title,
      body,
      notificationDetails,
    );
  }

  // Get Access tocken
  static Future<String> getAccessToken() async {
    try {
      Map<String, dynamic> serviceAccountJson = {};

      String? serviceAccountString = dotenv.env["GOOGLE_CLOUD_SERVICE_CREDENTIAL"];

      if (serviceAccountString != null) {
        serviceAccountJson = jsonDecode(serviceAccountString);
      }

      List<String> scopes = ["https://www.googleapis.com/auth/firebase.messaging"];

      http.Client client = await auth.clientViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

      // get access token
      auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes, client);

      client.close();
      return credentials.accessToken.data;
    } catch (e) {
      log("Error getting access token: $e");
      rethrow;
    }
  }

// Send push notification to another user
  Future<void> sendNotification(String receiverToken, String title, String bodyMsg, String type,
      String reciverId, String bookId) async {
    try {
      String serverKey = await getAccessToken();

      final Uri url =
          Uri.parse('https://fcm.googleapis.com/v1/projects/readify-project-7e631/messages:send');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      };

      final body = jsonEncode({
        'message': {
          'token': receiverToken,
          'notification': {
            'title': title,
            'body': bodyMsg,
          },
          'data': {
            'type': type,
            "message_id": reciverId,
            "sender_id": FirebaseAuth.instance.currentUser!.uid,
          },
        },
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        DatabaseService().addNotification(reciverId, title, bodyMsg, type, bookId: bookId);
        log("Notification sent successfully");
      } else {
        log("Error sending notification: ${response.body}");
      }
    } catch (e) {
      log("Exception during notification send: $e");
    }
  }

  // Broadcast a notification
  Future<void> broadcastNotification(
      String title, String bodyMsg, String type, String bookId) async {
    try {
      List<Map<String, dynamic>> users = await DatabaseService().getAllUsers();
      for (var user in users) {
        await sendNotification(
          user["fcm_token"],
          title,
          bodyMsg,
          type,
          user["uid"],
          bookId,
        );
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
