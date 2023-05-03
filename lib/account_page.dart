//Core
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/src/friends_page.dart';
import 'package:wya_final/src/utils/constants.dart';
import 'package:wya_final/welcome_page.dart';

import 'app_state.dart';
import 'src/widgets.dart';


class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  final _nameFormKey = GlobalKey<FormState>(debugLabel: '_AccountPageStateNameForm');
  final _usernameFormKey = GlobalKey<FormState>(debugLabel: '_AccountPageStateNameForm');
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _usernameController = TextEditingController();

  Future<void> addNameWidget() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Consumer<ApplicationState>(
            builder: (context, appState, _) => AlertDialog(
            title: const Text('Add your name'),
            content: Form(
              key: _nameFormKey,
              child: SizedBox(height:70, width: 300,
                  child:
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your name to continue';
                      }
                      return null;
                    },
                  )),
            ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    _nameController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Done'),
                  onPressed: () async {
                    if (_nameFormKey.currentState!.validate()) {
                      await appState.changeName(_nameController.text);
                      _nameController.clear();
                      Navigator.of(context).pop();
                    }

                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> changeUsernameWidget() async {
    String error = '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Consumer<ApplicationState>(
          builder: (context, appState, _) => AlertDialog(
            title: const Text('Change your username'),
            content: Form(
              key: _usernameFormKey,
              child: SizedBox(height:70, width: 300,
                  child:
                  Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your username',
                        ),
                        validator: (value) {
                          if (value == appState.userData.username){
                            return null;
                          }else if(value == null || value.isEmpty){
                            return 'Please enter a username.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10, child:
                        Text(error),
                        )
                    ],
                  )),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  _usernameController.clear();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Done'),
                onPressed: () async {
                  bool isUnique = await appState.usernameIsUnique(_usernameController.text);
                  if (isUnique && _usernameFormKey.currentState!.validate()) {
                    error = '';
                    await appState.changeUsername(_usernameController.text);
                    _usernameController.clear();
                    Navigator.of(context).pop();
                  }else{
                    error = 'Sorry, that username already exists.';
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => appState.loggedIn ? Scaffold(
        appBar: AppBar(
          title: const Text('WYA'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: CircleAvi(
                        imageSrc: appState.userData.photoUrl.isNotEmpty ? NetworkImage(
                          appState.userData.photoUrl,
                        ) : Image.asset('assets/images/noProfilePic.png').image,
                        size: 120,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 10,),
                          Text(
                            '@${appState.userData.username}',
                            style: kHandleTextStyle,
                          ),
                          IconButton(onPressed: () {changeUsernameWidget();} , icon: const Icon(Icons.edit, color: Colors.deepPurple,))
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: appState.userData.name.isEmpty ?
                          TextButton(onPressed: () { addNameWidget(); },
                          child: const Text('Add name'),) :
                      Text(
                        appState.userData.name,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StatColumn(num: appState.userData.events.length, label: "events", pushTo: (){context.push('/events');}),
                          StatColumn(num: appState.userData.friends.length, label: "friends", pushTo: (){context.push('/friends');}),
                        ],
                      ),
                    ),
                  ],
                )
                ),
                Expanded(child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: const <Widget> [
                      OptionTile(iconData: Icons.emoji_people, title: 'Friends', pushTo: '/friends'),
                      OptionTile(iconData: Icons.forest, title: 'Events', pushTo: '/events'),
                      OptionTile(iconData: Icons.settings, title: 'Settings', pushTo: '/settings'),
                    ],
                  ),
                ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomAppBarCustom(current: 'account',),
      ) : const WelcomePage(),
    );

  }
}

