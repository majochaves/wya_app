import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/notification_info.dart';
import '../../models/shared_event.dart';
import '../../providers/event_provider.dart';
import '../widgets.dart';

class NotificationType0 extends StatelessWidget {
  final NotificationInfo notification;
  const NotificationType0({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.go('/friends');
      },
      child: ListTile(
        leading: CircleAvi(
          imageSrc: NetworkImage(notification.user.photoUrl),
          size: 30,
        ),
        title: Text('${notification.user.username} sent you a follow request'),
      ),
    );
  }
}

class NotificationType1 extends StatelessWidget {
  final NotificationInfo notification;
  const NotificationType1({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.go('/friends');
      },
      child: ListTile(
        leading: CircleAvi(
          imageSrc: NetworkImage(notification.user.photoUrl),
          size: 30,
        ),
        title:
        Text('${notification.user.username} accepted your follow request'),
      ),
    );
  }
}

class NotificationType2 extends StatelessWidget {
  final NotificationInfo notification;
  const NotificationType2({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
        builder: (context, eventProvider, _) => InkWell(
          onTap: () {
            eventProvider.selectedEvent = notification.event;
            context.go('/viewEvent');
          },
          child: ListTile(
            leading: CircleAvi(
              imageSrc: NetworkImage(notification.user.photoUrl),
              size: 30,
            ),
            title: Text(
                '${notification.user.username} has requested to join your event'),
          ),
        ));
  }
}

class NotificationType3 extends StatelessWidget {
  final NotificationInfo notification;
  const NotificationType3({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
        builder: (context, eventProvider, _) => InkWell(
          onTap: () {
            eventProvider.selectedSharedEvent =
                SharedEvent(notification.event!, notification.user);
            context.go('/viewSharedEvent');
          },
          child: ListTile(
            leading: CircleAvi(
              imageSrc: NetworkImage(notification.user.photoUrl),
              size: 30,
            ),
            title: Text(
                '${notification.user.username} accepted your request to join their event'),
          ),
        ));
  }
}

class NotificationType4 extends StatelessWidget {
  final NotificationInfo notification;
  const NotificationType4({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
        builder: (context, eventProvider, _) => InkWell(
          onTap: () {
            eventProvider.selectedEvent = notification.event;
            context.go('/viewEvent');
          },
          child: ListTile(
            leading: CircleAvi(
              imageSrc: NetworkImage(notification.user.photoUrl),
              size: 30,
            ),
            title:
            Text('${notification.user.username} has joined your event'),
          ),
        ));
  }
}