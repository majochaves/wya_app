import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat.dart' as model;
import '../models/message.dart' as model;
class ChatService {
  ChatService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;


  Stream<List<model.Chat>> getChats(List chats) {
    return _db
        .collection('chats')
        .where('chatId', whereIn: chats)
        .orderBy('lastMessageSentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((document) => model.Chat.fromSnap(document))
        .toList());
  }

  Stream<List<model.Message>> getMessagesStream(String chatId) {
    return _db
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('created')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((document) => model.Message.fromSnap(document))
        .toList());
  }

  Future<List<model.Message>> getMessages(String chatId) async {
    List<model.Message> messages = [];
    QuerySnapshot mess = await FirebaseFirestore.instance
        .collection('messages').where('chatId', isEqualTo: chatId)
        .get();
    for(final message in mess.docs){
      model.Message m = model.Message.fromSnap(message);
      messages.add(m);
    }
    return messages;

  }

  Future<void> saveChat(model.Chat chat) async {
    await _db.collection('chats')
        .doc(chat.chatId)
        .set(chat.toJson());
  }

  Future<void> saveMessage(model.Message newMessage) async {
    await _db
        .collection('messages')
        .doc(newMessage.messageId)
        .set(newMessage.toJson());
  }

  Future<void> addNewMessageToChat(model.Message newMessage) async {
    await _db.collection('messages')
        .doc(newMessage.messageId)
        .set(newMessage.toJson());
    FirebaseFirestore.instance.collection('chats')
        .doc(newMessage.chatId)
        .update({
      'messages': FieldValue.arrayUnion([newMessage.messageId]),
      'lastMessageId': newMessage.messageId,
      'lastMessageSentAt': newMessage.dateSent
    });
  }

  Future<void> setReadMessages(String chatId, String uid) async {
    QuerySnapshot mess = await _db
        .collection('messages').where('chatId', isEqualTo: chatId)
        .where('senderId', isNotEqualTo: uid)
        .get();
    for (final message in mess.docs) {
      await FirebaseFirestore.instance.collection('messages').doc(
          (message.data() as Map<String, dynamic>)['messageId']).update(
          {'isRead': true});
    }
  }
}