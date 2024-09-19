import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: constant_identifier_names
enum MessageType { Text, Media }

class Message{
  String senderID;
  String receiverID;
  String content;
  MessageType messageType;
  Timestamp sentAt;
  String? mediaUrl;

  Message({
    required this.senderID,
    required this.receiverID,
    required this.content,
    required this.messageType,
    required this.sentAt,
    this.mediaUrl,
  });

  Message.fromJson(Map<String, dynamic> json)
      : senderID = json['senderID'] ?? '',
        receiverID = json['receiverID'] ?? '',
        content = json['content'] ?? '',
        messageType = MessageType.values.byName(json['messageType'] as String),
        sentAt = json['sentAt'],
        mediaUrl = json['mediaUrl'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderID'] = senderID;
    data['receiverID'] = receiverID;
    data['content'] = content;
    data['messageType'] = messageType.name;
    data['sentAt'] = sentAt;
    data['mediaUrl'] = mediaUrl;
    return data;
  }
}