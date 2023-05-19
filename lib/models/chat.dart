import 'package:cloud_firestore/cloud_firestore.dart';

class Chat{
  final String chatId;
  final String uid1;
  final String uid2;
  final List messages;
  final String? lastMessage;
  final DateTime? lastMessageSentAt;

  Chat({required this.chatId, required this.uid1, required this.uid2,
  required this.messages, required this.lastMessage, required this.lastMessageSentAt});

  Map<String, dynamic> toJson() => {
    "chatId" : chatId,
    "uid1" : uid1,
    "uid2" : uid2,
    "messages" : messages,
    "lastMessage" :lastMessage,
    "lastMessageSentAt" : lastMessageSentAt
  };

  static Chat fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Chat(
      chatId: snapshot['chatId'],
      uid1: snapshot['uid1'],
      uid2: snapshot['uid2'],
      messages : snapshot['messages'],
      lastMessage: snapshot['lastMessage'],
      lastMessageSentAt : snapshot['lastMessageSentAt'] == null ? null : DateTime.parse(snapshot['lastMessageSentAt'].toDate().toString()),
    );
  }

}