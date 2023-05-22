import 'package:flutter/material.dart';

import '../../models/notification_info.dart';
import '../../utils/string_formatter.dart';
import 'notification_types.dart';


class NotificationsBuilder extends StatefulWidget {
  final Map<DateTime, List<NotificationInfo>> notifications;
  const NotificationsBuilder({Key? key, required this.notifications})
      : super(key: key);

  @override
  State<NotificationsBuilder> createState() => _NotificationsBuilderState();
}

class _NotificationsBuilderState extends State<NotificationsBuilder> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> getNotificationTiles() {
    List<Widget> notificationTiles = [];
    for(MapEntry day in widget.notifications.entries){
      notificationTiles.add(Text(StringFormatter.getDayTitle(day.key)));
      for (NotificationInfo n in day.value) {
        if (n.notification.type == 0) {
          notificationTiles.add(NotificationType0(
            notification: n,
          ));
        } else if (n.notification.type == 1) {
          notificationTiles.add(NotificationType1(
            notification: n,
          ));
        } else if (n.notification.type == 2) {
          notificationTiles.add(NotificationType2(
            notification: n,
          ));
        } else if (n.notification.type == 3) {
          notificationTiles.add(NotificationType3(
            notification: n,
          ));
        } else {
          notificationTiles.add(NotificationType4(
            notification: n,
          ));
        }
      }
    }
    return notificationTiles;
  }

  @override
  Widget build(BuildContext context) {
    return widget.notifications.isEmpty
        ? const Center(child: Text('You have no notifications'))
        : ListView(
      children: getNotificationTiles(),
    );
  }
}