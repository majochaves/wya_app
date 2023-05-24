import 'package:cloud_firestore/cloud_firestore.dart';

class Chat{
  final String chatId;
  final List participants;
  final String? lastMessage;
  final DateTime? lastMessageSentAt;

  Chat({required this.chatId, required this.participants,
  required this.lastMessage, required this.lastMessageSentAt});

  Map<String, dynamic> toJson() => {
    "chatId" : chatId,
    "participants" : participants,
    "lastMessage" :lastMessage,
    "lastMessageSentAt" : lastMessageSentAt
  };

  static Chat fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Chat(
      chatId: snapshot['chatId'],
      participants: snapshot['participants'],
      lastMessage: snapshot['lastMessage'],
      lastMessageSentAt : snapshot['lastMessageSentAt'] == null ? null : DateTime.parse(snapshot['lastMessageSentAt'].toDate().toString()),
    );
  }

}