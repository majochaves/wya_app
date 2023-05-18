//Core
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/src/utils/constants.dart';
import 'package:wya_final/src/pages/welcome_page.dart';

import '../../app_state.dart';
import '/src/widgets/widgets.dart';


class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => appState.loggedIn ? Scaffold(
        appBar: AppBar(
          backgroundColor: kWYATeal,
          title: Image(image: Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/wyatextorange.png').image, width: 80,),
          actions: [
            IconButton(onPressed: (){
              FirebaseAuth.instance.signOut();
      }, icon: const Icon(Icons.logout)),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
              color: Colors.white
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(child: Column(
                    children: <Widget>[
                      const SizedBox(height: 20,),
                      Expanded(
                        flex: 4,
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundColor: Colors.transparent,
                          backgroundImage: appState.userData.photoUrl.isNotEmpty ? Image.network(
                            appState.userData.photoUrl,
                          ).image : Image.asset('assets/images/noProfilePic.png').image,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '@${appState.userData.username}',
                              style: kHandleTextStyle,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child:
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
                            StatColumn(num: appState.userData.events.length, label: "events", pushTo: '/events', isEnabled: true),
                            StatColumn(num: appState.userData.friends.length, label: "friends", pushTo: '/friends', isEnabled: true),
                          ],
                        ),
                      ),
                    ],
                  )
                  ),
                  Expanded(child: Column(
                    children: const <Widget> [
                      OptionTile(iconData: Icons.emoji_people, title: 'Friends', pushTo: '/friends'),
                      OptionTile(iconData: Icons.calendar_month, title: 'Events', pushTo: '/events'),
                      OptionTile(iconData: Icons.settings, title: 'Settings', pushTo: '/settings'),
                    ],
                  ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const BottomAppBarCustom(current: 'account',),
      ) : const WelcomePage(),
    );

  }
}

