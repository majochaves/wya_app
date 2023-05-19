import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/models/message.dart' as model;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:wya_final/utils/constants.dart';
import '/widgets/widgets.dart';
import 'package:wya_final/models/user_data.dart';
import 'package:wya_final/pages/welcome_page.dart';

import '../../app_state.dart';

class ChatViewer extends StatefulWidget {
  const ChatViewer({Key? key}) : super(key: key);

  @override
  State<ChatViewer> createState() => _ChatViewerState();
}

class _ChatViewerState extends State<ChatViewer> {

  List<types.Message> getMessages(List<model.Message> chatMessages){
    return chatMessages.map((e) => types.TextMessage(author: types.User(id: e.senderId), createdAt: e.dateSent.millisecondsSinceEpoch,
    id: e.messageId, text: e.text)).toList().reversed.toList();
  }

  types.User getUser(UserData user){
    return types.User(id: user.uid);
  }

  void setReadMessages() async{
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = Provider.of<ApplicationState>(context, listen: false);
      await appState.setReadMessages();
    });
  }

  @override
  void initState() {
    super.initState();
    setReadMessages();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => appState.loggedIn ? Scaffold(
        appBar: AppBar(
          backgroundColor: kWYATeal,
          title: Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(appState.selectedChat!.user.photoUrl), radius: 25,),
              const SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(appState.selectedChat!.user.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                Text(appState.selectedChat!.user.username, style: const TextStyle(fontSize: 10, color: Colors.white),),
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
                  messages: getMessages(appState.selectedChat!.messages),
                  user: getUser(appState.userData),
                  onSendPressed: appState.handleNewMessage,
                ),
              ),
            ],
          )
        ),
    ) : const WelcomePage() );
  }
}
