import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

import 'package:wya_final/providers/user_provider.dart';
import 'package:wya_final/services/chat_service.dart';
import 'package:wya_final/services/user_service.dart';

import '../models/chat_info.dart';
import '../models/user_data.dart';
import '../models/chat.dart' as model;
import '../models/message.dart' as model;

class ChatProvider extends ChangeNotifier {
  static const Uuid uuid = Uuid();
  final User? user = FirebaseAuth.instance.currentUser;

  ///Constructor
  ChatProvider(){
    init();
  }

  ///ChangeNotifierProxy Update Method: Updates when UserProvider has been updated
  void update(UserProvider provider){
    friendInfo = provider.friendInfo;
    notifyListeners();
  }

  ///Services
  ChatService chatService = ChatService();
  UserService userService = UserService();

  ///Shared data from User provider
  List<UserData> friendInfo = [];

  ///Provider values
  List<ChatInfo> chats = [];
  ChatInfo? _selectedChat;
  ChatInfo? get selectedChat => _selectedChat;
  set selectedChat(ChatInfo? newSelectedChat){
    _selectedChat = newSelectedChat;
    if(newSelectedChat != null){
      currentChatMessagesStream = chatService.getMessagesStream(newSelectedChat.chat.chatId).listen((event) {
        selectedChat!.messages = event;
        notifyListeners();
      });
    }else{
      currentChatMessagesStream?.cancel();
    }
  }
  int get unreadMessages{
    int unread = 0;
    for(ChatInfo chat in chats){
      for(model.Message m in chat.messages){
        if(m.senderId != user!.uid && !m.isRead){
          unread++;
        }
      }
    }
    return unread;
  }

  StreamSubscription? getChatStream;
  StreamSubscription? currentChatMessagesStream;


  void cancelStreams(){
    getChatStream?.cancel();
    currentChatMessagesStream?.cancel();
  }

  void clearData(){
    friendInfo.clear();
    chats.clear();
    selectedChat = null;
    notifyListeners();
  }

  ///Get chats from chat stream
  void init(){
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        getChatStream = chatService.getChats(FirebaseAuth.instance.currentUser!.uid).listen((chatList) async {
          print('getting chat stream for user: ${user.uid}');
          for (model.Chat chat in chatList) {
            List<model.Message> messages = await chatService.getMessages(chat.chatId);
            UserData? friend = await getFriendForChat(chat);
            ChatInfo chatInfo = ChatInfo(chat: chat, messages: messages, user: friend!);
            if (chats.any((element) =>
            element.chat.chatId == chatInfo.chat.chatId)) {
              chats[chats.indexWhere((element) =>
              element.chat.chatId == chatInfo.chat.chatId)] =
                  chatInfo;
              if (selectedChat != null) {
                if (selectedChat!.chat.chatId == chatInfo.chat.chatId) {
                  selectedChat = chatInfo;
                }
              }
            } else {
              chats.add(chatInfo);
            }
          }
        });

      }else{
        cancelStreams();
        clearData();
        print('chat provider: reset');
      }
    });
  }

  ///Auxiliary method to get UserData for chat participant
  Future<UserData?> getFriendForChat(model.Chat chat) async{
    for(String id in chat.participants){
      if(id != user!.uid){
        if(friendInfo.any((element) => element.uid == id)){
          return friendInfo[friendInfo.indexWhere((element) => element.uid == id)];
        }else{
          return await userService.getUserById(id);
        }
      }
    }
    return null;
  }

  ///Provider methods
  void handleNewMessage(types.PartialText message) {
    model.Message newMessage
      = model.Message(
          messageId: uuid.v1(),
          senderId: user!.uid,
          chatId: selectedChat!.chat.chatId,
          text: message.text,
          dateSent: DateTime.now(),
          isRead: false
      );
    selectedChat!.messages.insert(selectedChat!.messages.length, newMessage);
    chatService.addNewMessageToChat(newMessage);
  }

  Future<void> startChatWith(UserData friend) async{
    bool foundChat = false;
    for(ChatInfo chat in chats){
      if(chat.user.uid == friend.uid){
        foundChat = true;
        selectedChat = chat;
      }
    }
    if(!foundChat) {
      model.Chat newChat = model.Chat(chatId: const Uuid().v1(),
          participants: [user!.uid, friend.uid],
          lastMessage: null,
          lastMessageSentAt: null);
      chatService.saveChat(newChat);
      userService.addChat(user!.uid, newChat.chatId);
      userService.addChat(friend.uid, newChat.chatId);
      selectedChat = ChatInfo(chat: newChat, messages: [], user: friend);
    }
  }

  Future<void> setReadMessages() async{
    chatService.setReadMessages(selectedChat!.chat.chatId, user!.uid);
  }
}
