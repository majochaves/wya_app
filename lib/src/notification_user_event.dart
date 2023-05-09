import 'package:wya_final/notification.dart' as model;
import 'package:wya_final/event.dart' as model;
import 'package:wya_final/user_data.dart';

class NotificationUserEvent{
  final model.Notification notification;
  final UserData user;
  final model.Event? event;

  NotificationUserEvent({required this.notification, required this.user, required this.event});
}