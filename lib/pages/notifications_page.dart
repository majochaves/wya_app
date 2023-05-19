import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '/widgets/widgets.dart';
import 'package:wya_final/pages/welcome_page.dart';

import 'package:wya_final/app_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  @override
  void initState() {
    super.initState();
    setReadNotifications();
  }

  void setReadNotifications(){
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = Provider.of<ApplicationState>(context, listen: false);
      appState.setReadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => appState.loggedIn ? Scaffold(
        appBar: AppBar(
          backgroundColor: kWYATeal,
          title: Text('Notifications', style: GoogleFonts.pattaya(textStyle: const TextStyle(color: Colors.white)),),),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Visibility(visible: appState.notifications.isEmpty,
                    child: const Center(child: Text('You have no notifications'),)),
                Visibility(visible: appState.notifications.isNotEmpty, child:
                  Expanded(child: NotificationsBuilder(notifications: appState.notifications))),
          ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomAppBarCustom(current: 'home',),
      ) : const WelcomePage(),
    );
  }
}
