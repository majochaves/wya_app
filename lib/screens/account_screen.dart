//Core
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/providers/chat_provider.dart';
import 'package:wya_final/providers/event_provider.dart';
import 'package:wya_final/providers/group_provider.dart';
import 'package:wya_final/providers/notification_provider.dart';
import 'package:wya_final/providers/user_provider.dart';
import 'package:wya_final/screens/welcome_screen.dart';
import 'package:wya_final/utils/constants.dart';
import '../providers/auth_provider.dart';
import '/widgets/widgets.dart';


class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context);
    final userProvider = Provider.of<UserProvider>(context);
    return authProvider.loggedIn ?  Scaffold(
      appBar: AppBar(
        backgroundColor: kWYATeal,
        title: Image(image: Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/wyatextorange.png').image, width: 80,),
        actions: [
          IconButton(onPressed: (){
            FirebaseAuth.instance.signOut();
          }, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: UserDetailsViewer(
                  photoUrl: userProvider.photoUrl!,
                  username: userProvider.username!,
                  name: userProvider.name!,
                  friendsCount: userProvider.friends.length,
                  eventsCount: userProvider.events.length, isUserAccount: true),
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
      bottomNavigationBar: const CustomBottomAppBar(current: 'account',),
    ) : const WelcomeScreen();
  }
}

