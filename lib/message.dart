import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  final String messageId;
  final String senderId;
  final String chatId;
  final String text;
  final DateTime dateSent;
  bool isRead;

  Message({required this.messageId, required this.senderId,
    required this.chatId, required this.text, required this.dateSent, required this.isRead});

  Map<String, dynamic> toJson() => {
    "messageId" : messageId,
    "senderId" : senderId,
    "chatId" : chatId,
    "text" : text,
    "dateSent" : dateSent,
    "isRead" : isRead,
  };

  static Message fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Message(
        messageId: snapshot['messageId'],
        senderId: snapshot['senderId'],
        chatId: snapshot['chatId'],
        text: snapshot['text'],
        dateSent: DateTime.parse(snapshot['dateSent'].toDate().toString()),
        isRead : snapshot['isRead'],
    );
  }

}