import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/src/widgets.dart';
import 'package:wya_final/welcome_page.dart';

import 'app_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => appState.loggedIn ? Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Visibility(visible: appState.notificationsToday.isEmpty && appState.notificationsPastWeek.isEmpty,
                    child: const Center(child: Text('You have no notifications'),)),
                Visibility(visible: appState.notificationsToday.isNotEmpty, child: Text('Today')),
                Visibility(visible: appState.notificationsToday.isNotEmpty, child:
                  Expanded(child: NotificationsBuilder(notifications: appState.notificationsToday))),
                Visibility(visible: appState.notificationsPastWeek.isNotEmpty, child: const Text('This week')),
                Visibility(visible: appState.notificationsPastWeek.isNotEmpty, child:
                Expanded(child: NotificationsBuilder(notifications: appState.notificationsPastWeek))),
          ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomAppBarCustom(current: 'home',),
      ) : const WelcomePage(),
    );
  }
}
