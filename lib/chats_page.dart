import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/src/utils/constants.dart';
import 'package:wya_final/src/widgets.dart';
import 'package:wya_final/user_data.dart';
import 'package:wya_final/welcome_page.dart';

import 'app_state.dart';
import 'chat_info.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

List<Widget> getChatList(List<ChatInfo> chats){
  List<Widget> chatList = [];
  for(ChatInfo chat in chats){
    chatList.add(ChatPreviewer(chat: chat));
  }
  return chatList;
}

class _ChatsPageState extends State<ChatsPage> {

  List<UserData> friends = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final appState = Provider.of<ApplicationState>(context, listen: false);
      appState.selectedChat = null;
      friends = appState.friends;
    });
  }

  Future<void> _newChatWindow() async {
    bool isLoading = false;
    List<UserData> friendSearch = List.from(friends);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return friends.isEmpty
            ? AlertDialog(
          content: const SizedBox(
            height: 100,
            width: 300,
            child: Center(
              child: Text(
                  'You have no friends. Add one to start a chat.'),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        )
            : AlertDialog(
          title: const Text('New message: '),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Consumer<ApplicationState>(
                  builder: (context, appState, _) =>
                  SizedBox(
                    height: 350,
                    width: 300,
                    child: isLoading ?
                    const Center(child: CircularProgressIndicator(),) : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text(
                          'To: ',
                          style: kH4SourceSansTextStyle,
                        ),
                        ListTile(
                          leading: const Icon(Icons.search),
                          title: TextField(controller: searchController,
                              decoration: const InputDecoration(hintText: 'Search', border: InputBorder.none
                            ), onChanged: (text) {
                              setState(() {
                                friendSearch = [];
                                if (text.isEmpty) {
                                  friendSearch = List.from(friends);
                                }
                                for (var friend in friends) {
                                  if (friend.name.contains(text) || friend.username.contains(text)) {
                                    if(!friendSearch.contains(friend)) {friendSearch.add(friend);}
                                  }
                                }
                              });
                            },),
                          trailing: IconButton(icon: const Icon(Icons.cancel), onPressed: () {
                            searchController.clear();
                            setState(() {
                              friendSearch = [];
                            });
                          },),
                        ),
                        friendSearch.isEmpty ? const Center(child: Text('No friends found'),) : Expanded(
                          flex: 4,
                          child: UserListTiles(
                              users: friendSearch,
                              icon: Icons.check,
                              onPressed: (user) async {
                                  setState((){
                                    isLoading = true;
                                  });
                                  await appState.startChatWith(user);
                                  context.go('/viewChat');
                              }),
                        ),
                      ],
                    ),
                  ),);
              }),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => appState.loggedIn ? Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          actions: [IconButton(onPressed: (){
            _newChatWindow();
          }, icon: const Icon(Icons.chat))],
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                appState.chats.isEmpty ? const Center(child: Text('You have no chats'),) :
                Expanded(child: ListView(children: getChatList(appState.chats),))
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomAppBarCustom(current: 'home',),
      ) : const WelcomePage(),
    );
  }
}
