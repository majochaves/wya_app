import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/providers/notification_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/notification_widgets/notifications_builder.dart';
import '/widgets/widgets.dart';
import 'package:wya_final/screens/welcome_screen.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  @override
  void initState() {
    super.initState();
    setReadNotifications();
  }

  void setReadNotifications(){
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.setReadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    return authProvider.loggedIn ? Scaffold(
        appBar: AppBar(
          backgroundColor: kWYATeal,
          title: Text('Notifications', style: GoogleFonts.pattaya(textStyle: const TextStyle(color: Colors.white)),),),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Visibility(visible: notificationProvider.notifications.isEmpty,
                    child: const Center(child: Text('You have no notifications'),)),
                Visibility(visible: notificationProvider.notifications.isNotEmpty, child:
                  Expanded(child: NotificationsBuilder(notifications: notificationProvider.notifications))),
          ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomAppBar(current: 'home',),
      ) : const WelcomeScreen();
  }
}
