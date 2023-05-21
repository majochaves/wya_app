import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

  ///Get notifications from Notification Stream
  void init() {
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        notificationService.getNotifications().listen((notificationsList) {
          for(model.Notification notification in notificationsList){
            Event notificationEvent;
            UserData notificationUser = getFriendFromId(notification.userId);
            if(notification.type == 2 || notification.type == 4){
              notificationEvent = getEventFromId(notification.eventId);
            }else{
              notificationEvent = getSharedEventFromId(notification.eventId);
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
          notifyListeners();
        });
      }
    });
  }

  ///Aux methods to get user and event data mentioned in notification
  UserData getFriendFromId(String id){
    return friendInfo[friendInfo.indexWhere((element) => element.uid == id)];
  }

  Event getEventFromId(String id){
    return events[events.indexWhere((element) => element.eventId == id)];
  }

  Event getSharedEventFromId(String id){
    return sharedEvents[sharedEvents.indexWhere((element) => element.event.eventId == id)].event;
  }

  ///Provided methods
  Future<void> setReadNotifications() async{
    notificationService.setReadNotifications(user!.uid);
  }

}