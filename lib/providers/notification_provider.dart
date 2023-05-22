import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wya_final/services/event_service.dart';
import 'package:wya_final/services/user_service.dart';

import '../models/event.dart';
import '../models/notification_info.dart';
import '../models/shared_event.dart';
import '../models/user_data.dart';
import '../services/notification_service.dart';
import '/models/notification.dart' as model;
import 'event_provider.dart';


class NotificationProvider extends ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;

  ///Constructor
  NotificationProvider(){
    init();
  }

  ///ChangeNotifierProxy Update Method: Updates when EventProvider has been updated
  void update(EventProvider provider){
    friendInfo = provider.friendInfo;
    events = provider.events;
    sharedEvents = provider.sharedEvents;
    notifyListeners();
  }

  ///Services
  NotificationService notificationService = NotificationService();
  EventService eventService = EventService();
  UserService userService = UserService();

  ///Shared data from Event provider
  List<SharedEvent> sharedEvents = [];
  List<Event> events = [];
  List<UserData> friendInfo = [];

  ///Provider values
  Map<DateTime, List<NotificationInfo>> notifications = {};
  int get unreadNotifications{
    int unread = 0;
    for(MapEntry entry in notifications.entries){
      for(NotificationInfo n in entry.value){
        if(!n.notification.isRead){
          unread++;
        }
      }
    }
    return unread;
  }

  StreamSubscription? getNotificationStream;

  void cancelStreams(){
    getNotificationStream?.cancel();
  }

  ///Get notifications from Notification Stream
  void init() {
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        getNotificationStream = notificationService.getNotifications(user.uid).listen((notificationsList) async {
          for(model.Notification notification in notificationsList){
            Event? notificationEvent;
            UserData notificationUser = await getFriendFromId(notification.userId);
            if(notification.eventId != ''){
              if(notification.type == 2 || notification.type == 4){
                notificationEvent = getEventFromId(notification.eventId);
              }else{
                notificationEvent = await getSharedEventFromId(notification.eventId);
              }
            }

            NotificationInfo notInfo = NotificationInfo(notification: notification, user: notificationUser, event: notificationEvent);

            DateTime dayOfNotification = DateTime(notification.created.year, notification.created.month, notification.created.day, 0, 0);
            if(!notifications.containsKey(dayOfNotification)){
              notifications.putIfAbsent(dayOfNotification, () => []);
            }

            if(notifications[dayOfNotification]!.any((element) => element.notification.notificationId == notification.notificationId)){
              notifications[dayOfNotification]![notifications[dayOfNotification]!.indexWhere((element) => element.notification.notificationId == notification.notificationId)] = notInfo;
            }else{
              notifications[dayOfNotification]!.add(notInfo);
            }
          }
          notifications = Map.fromEntries(
              notifications.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
          notifyListeners();
        });
      }else{
        getNotificationStream?.cancel();
      }
    });
  }

  ///Aux methods to get user and event data mentioned in notification
  Future<UserData> getFriendFromId(String id) async{
    if(friendInfo.any((element) => element.uid == id)){
      return friendInfo[friendInfo.indexWhere((element) => element.uid == id)];
    }else{
      return await userService.getUserById(id);
    }

  }

  Event getEventFromId(String id){
    return events[events.indexWhere((element) => element.eventId == id)];
  }

  Future<Event> getSharedEventFromId(String id) async{
    if(sharedEvents.any((element) => element.event.eventId == id)){
      return sharedEvents[sharedEvents.indexWhere((element) => element.event.eventId == id)].event;
    }else{
      return await eventService.getEventById(id);
    }

  }

  ///Provided methods
  Future<void> setReadNotifications() async{
    notificationService.setReadNotifications(user!.uid);
  }

}