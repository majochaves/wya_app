import 'package:wya_final/src/models/chat.dart';
import 'package:wya_final/src/models/message.dart' as model;
import 'package:wya_final/src/models/user_data.dart';
class ChatInfo{
  Chat chat;
  List<model.Message> messages;
  UserData user;

  ChatInfo({required this.chat, required this.messages, required this.user});
}