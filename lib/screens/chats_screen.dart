import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/utils/constants.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '/widgets/widgets.dart';
import 'package:wya_final/models/user_data.dart';
import '../models/chat_info.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

List<Widget> getChatList(List<ChatInfo> chats){

  List<Widget> chatList = [];
  if(chats.isNotEmpty){
    for(ChatInfo chat in chats){
      chatList.add(ChatPreviewer(chat: chat));
    }
  }
  return chatList;
}

class _ChatsScreenState extends State<ChatsScreen> {

  List friends = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      chatProvider.selectedChat = null;
      friends = userProvider.friendInfo;
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
                return Consumer<ChatProvider>(
                  builder: (context, chatProvider, _) =>
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
                          child: UserInkWellListTiles(
                              users: friendSearch,
                              onPressed: (user) async {
                                  setState((){
                                    isLoading = true;
                                  });
                                  await chatProvider.startChatWith(user);
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
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWYATeal,
        title: Text('Chats', style: GoogleFonts.pattaya(textStyle: const TextStyle(color: Colors.white)),),
        actions: [IconButton(onPressed: (){
          _newChatWindow();
        }, icon: const Icon(Icons.chat))],),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              chatProvider.chats.isEmpty ? const Center(child: Text('You have no chats'),) :
              Expanded(child: ListView(children: getChatList(chatProvider.chats),))
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(current: 'home',),
    );
  }
}
