import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId, senderEmail, reciverId, message;
  final Timestamp timestamp;
  final bool viewed;

  const Message({
    required this.senderId,
    required this.senderEmail,
    required this.reciverId,
    required this.message,
    required this.timestamp,
    required this.viewed,
  });

  // Convert to map
  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "senderEmail": senderEmail,
      "reciverId": reciverId,
      "message": message,
      "timestamp": timestamp,
      "viewed": viewed
    };
  }
}
