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
  bool notificationsIsLoading = false;

  StreamSubscription? getNotificationStream;

  void cancelStreams(){
    getNotificationStream?.cancel();
  }

  void clearData(){
    notifications.clear();
    sharedEvents.clear();
    events.clear();
    friendInfo.clear();
    notifyListeners();
  }

  ///Get notifications from Notification Stream
  void init() {
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        getNotificationStream = notificationService.getNotifications(FirebaseAuth.instance.currentUser!.uid).listen((notificationsList) async {
          notificationsIsLoading = true;
          notifyListeners();
          print('getting notification stream for user: ${user.uid}');
          notifications = {};
          for(model.Notification notification in notificationsList){
            DateTime dayOfNotification = DateTime(notification.created.year, notification.created.month, notification.created.day, 0, 0);
            print('notification: ${notification.notificationId}');
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
            if(!notifications.containsKey(dayOfNotification)){
              notifications.putIfAbsent(dayOfNotification, () => []);
            }

            if(notifications[dayOfNotification]!.any((element) => element.notification.notificationId == notification.notificationId)){
              notifications[dayOfNotification]![notifications[dayOfNotification]!.indexWhere((element) => element.notification.notificationId == notification.notificationId)] = notInfo;
            }else{
              notifications[dayOfNotification]!.add(notInfo);
            }
          }
          notificationsIsLoading = false;
          notifyListeners();
        });
      }else{
        cancelStreams();
        clearData();
        print('notification provider: reset');
      }
    });
  }

  ///Aux methods to get user and event data mentioned in notification
  Future<UserData> getFriendFromId(String id) async{
    if(friendInfo.any((element) => element.uid == id)){
      return friendInfo[friendInfo.indexWhere((element) => element.uid == id)];
    }else{
      ///This is used in the case that the user mentioned in the notification is no longer friends with the current user
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
      ///This is used in the case that the event mentioned in the notification is no longer shared with the current user
      return await eventService.getEventById(id);
    }

  }

  ///Provided methods
  Future<void> setReadNotifications() async{
    notificationService.setReadNotifications(FirebaseAuth.instance.currentUser!.uid);
  }

}