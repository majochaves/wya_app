import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/models/message.dart' as model;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:wya_final/providers/chat_provider.dart';
import 'package:wya_final/providers/user_provider.dart';
import 'package:wya_final/utils/constants.dart';
import '../providers/auth_provider.dart';
import 'package:wya_final/models/user_data.dart';
import 'package:wya_final/screens/welcome_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  List<types.Message> getMessages(List<model.Message> chatMessages){
    return chatMessages.map((e) => types.TextMessage(author: types.User(id: e.senderId), createdAt: e.dateSent.millisecondsSinceEpoch,
    id: e.messageId, text: e.text)).toList().reversed.toList();
  }

  types.User getUser(UserData user){
    return types.User(id: user.uid);
  }

  void setReadMessages() async{
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.setReadMessages();
    });
  }

  @override
  void initState() {
    super.initState();
    setReadMessages();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kWYATeal,
          title: Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(chatProvider.selectedChat!.user.photoUrl), radius: 25,),
              const SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(chatProvider.selectedChat!.user.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                Text(chatProvider.selectedChat!.user.username, style: const TextStyle(fontSize: 10, color: Colors.white),),
              ],),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Chat(
                  theme: const DefaultChatTheme(primaryColor: kWYAOrange),
                  messages: getMessages(chatProvider.selectedChat!.messages),
                  user: getUser(userProvider.userData!),
                  onSendPressed: chatProvider.handleNewMessage,
                ),
              ),
            ],
          )
        ),
    );
  }
}
