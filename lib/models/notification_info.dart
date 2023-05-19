import 'package:wya_final/models/notification.dart' as model;
import 'package:wya_final/models/event.dart' as model;
import 'package:wya_final/models/user_data.dart';

class NotificationInfo{
  final model.Notification notification;
  final UserData user;
  final model.Event? event;

  NotificationInfo({required this.notification, required this.user, required this.event});
}