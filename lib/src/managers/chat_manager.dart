import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat.dart' as model;
import '../models/message.dart' as model;
class ChatManager{
  ChatManager();

  Future<void> createChat(model.Chat chat) async{
    await FirebaseFirestore.instance.collection('chats')
        .doc(chat.chatId)
        .set(chat.toJson());
  }

  Future<void> addNewMessageToChat(model.Message newMessage) async{
    FirebaseFirestore.instance.collection('messages').doc(newMessage.messageId).set(newMessage.toJson());
    FirebaseFirestore.instance.collection('chats').doc(newMessage.chatId).update({
    'messages': FieldValue.arrayUnion([newMessage.messageId]), 'lastMessageId' : newMessage.messageId, 'lastMessageSentAt' : newMessage.dateSent});
  }

  Future<void> setReadMessages(String chatId, String uid) async{
    QuerySnapshot mess = await FirebaseFirestore.instance
        .collection('messages').where('chatId', isEqualTo: chatId)
        .where('senderId', isNotEqualTo: uid)
        .get();
    for(final message in mess.docs){
      await FirebaseFirestore.instance.collection('messages').doc((message.data() as Map<String, dynamic>)['messageId']).update({'isRead' : true});
    }
  }
}