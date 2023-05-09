import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/message.dart' as model;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:wya_final/src/widgets.dart';
import 'package:wya_final/user_data.dart';
import 'package:wya_final/welcome_page.dart';

import 'app_state.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final appState = Provider.of<ApplicationState>(context, listen: false);
      appState.setReadMessages();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => appState.loggedIn ? Scaffold(
        appBar: AppBar(title: Text('WYA'), backgroundColor: Colors.purple.shade100,),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: Container(
                color: Colors.purple.shade100,
                child: Row(children: [
                  SizedBox(width: 20,),
                  CircleAvi(imageSrc: NetworkImage(appState.selectedChat!.user.photoUrl), size: 30,),
                  SizedBox(width: 20,),
                  Expanded(
                    child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(appState.selectedChat!.user.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                      Text(appState.selectedChat!.user.username, style: TextStyle(fontSize: 10, color: Colors.grey.shade800),),
                    ],),
                  )
                ],),
              )),
              Expanded(
                flex: 15,
                child: Chat(
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
