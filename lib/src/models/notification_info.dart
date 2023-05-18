import 'package:wya_final/src/models/notification.dart' as model;
import 'package:wya_final/src/models/event.dart' as model;
import 'package:wya_final/src/models/user_data.dart';

class NotificationInfo{
  final model.Notification notification;
  final UserData user;
  final model.Event? event;

  NotificationInfo({required this.notification, required this.user, required this.event});
}