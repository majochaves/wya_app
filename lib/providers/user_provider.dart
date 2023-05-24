import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wya_final/models/user_data.dart';
import 'package:wya_final/services/chat_service.dart';

import '../services/event_service.dart';
import '../services/group_service.dart';
import '../services/image_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../services/username_service.dart';
import '/models/notification.dart' as model;


class UserProvider extends ChangeNotifier {
  ///Constructor
  UserProvider(){
    init();
  }

  ///Services
  final userService = UserService();
  final usernameService = UsernameService();
  final imageService = ImageService();
  final notificationService = NotificationService();
  final eventService = EventService();
  final groupService = GroupService();
  final chatService = ChatService();
  final locationService = EventLocationService();
  var uuid = const Uuid();

  /// Provider values
  /* UserData model values*/
  String? email;
  String? uid;
  String? photoUrl;
  String? username;
  String? name;
  bool? allowAdd;
  int? maxMatchDistance;
  List friends = [];
  List pendingRequests = [];
  List requests = [];
  List groups = [];
  List events = [];
  List notifications = [];
  List chats = [];

  /* Additional values*/
  UserData? userData;
  List<UserData> friendInfo = [];
  List<UserData> requestInfo = [];
  bool isLoading = true;

  /*Streams*/
  StreamSubscription? getUserDataStream;
  StreamSubscription? getFriendsStream;
  StreamSubscription? getRequestsStream;


  ///Methods to reset provider once user has logged out
  void clearData(){
    email = null;
    uid = null;
    photoUrl = null;
    username = null;
    name = null;
    allowAdd = null;
    maxMatchDistance = null;
    friends.clear();
    pendingRequests.clear();
    requests.clear();
    groups.clear();
    events.clear();
    notifications.clear();
    chats.clear();
    friendInfo.clear();
    requestInfo.clear();
    isLoading = true;
    notifyListeners();
  }

  void cancelStreams(){
    getUserDataStream?.cancel();
    getRequestsStream?.cancel();
    getFriendsStream?.cancel();
  }


  ///Listens to streams and updates values
  void init() {
    FirebaseAuth.instance.userChanges().listen((user) {
      ///If user is logged in
      if (user != null) {
        getUserDataStream = userService.getUserData(user.uid).listen((event) {
          userData = event;
          email = userData!.email;
          uid = userData!.uid;
          username = userData!.username;
          name = userData!.name;
          photoUrl = userData!.photoUrl;
          allowAdd = userData!.allowAdd;
          maxMatchDistance = userData!.maxMatchDistance;
          friends = userData!.friends;
          requests = userData!.requests;
          groups = userData!.groups;
          events = userData!.events;
          notifications = userData!.notifications;
          chats = userData!.chats;
          isLoading = false;
          notifyListeners();
        });
        getFriendsStream = userService.getUserFriends(user.uid).listen((event) {
          friendInfo = event;
          notifyListeners();
        });
        getRequestsStream = userService.getUserRequests(user.uid).listen((event) {
          requestInfo = event;
          notifyListeners();
        });
      }else{
        ///If user is logged out
          cancelStreams();
          clearData();
          print('user provider: reset');
      }
    });
  }

  ///Provider methods
  /*Uniqueness verification methods*/
  Future<bool> emailIsUnique(String email) async {
    return userService.emailIsUnique(email, uid!);
  }

  Future<bool> usernameIsUnique(String val) async{
    return usernameService.usernameIsUnique(val);
  }

  /*Field update methods*/
  Future<void> changeEmail(String val) async{
    email = val;
    notifyListeners();
    await userService.changeEmail(val, uid!);
    await FirebaseAuth.instance.currentUser!.updateEmail(val);
  }

  Future<void> changeName(String val) async{
    email = val;
    notifyListeners();
    await userService.changeName(val, uid!);
    await FirebaseAuth.instance.currentUser!.updateDisplayName(val);
  }

  Future<void> changeProfilePicture(Uint8List file) async{
    String photoUrl = await imageService.uploadImageToStorage('profilePics', file, uid!);
    photoUrl = photoUrl;
    notifyListeners();
    await userService.changeProfilePicture(photoUrl, uid!);
    await FirebaseAuth.instance.currentUser!.updatePhotoURL(photoUrl);
  }

  Future<void> changeUsername(String val) async{
    await usernameService.deleteUsername(username!);
    await usernameService.saveUsername(val);
    username = val;
    notifyListeners();
    await userService.changeUsername(val, uid!);
  }

  Future<void> changeAllowAdd(bool val) async{
    allowAdd = val;
    notifyListeners();
    await userService.changeAllowAdd(val, uid!);
  }

  Future<void> changeMaxMatchDistance(int val) async{
    maxMatchDistance = val;
    notifyListeners();
    await userService.changeMaxMatchDistance(val.toDouble(), uid!);
  }

  /*Friend and request methods*/
  Future<void> addFriend(UserData user) async{
    if(!friends.contains(user.uid)){
      await userService.addFriend(uid!, user.uid);
      await userService.deleteRequest(uid!, user.uid);

      String notificationId = uuid.v1();
      model.Notification notification
        = model.Notification(
            notificationId:  notificationId,
            type: 1,
            created: DateTime.now(),
            uid: user.uid,
            isRead: false,
            userId: uid!,
            eventId: ''
        );

      notificationService.saveNotification(notification);
      userService.addNotification(user.uid, notificationId);
    }
  }

  Future<void> removeFriend(UserData user) async{
    if(friends.contains(user.uid)) {
      await userService.removeFriend(uid!, user.uid);
      eventService.removeFriendFromUserEvents(uid!, user.uid);
      groupService.removeFriendFromUserGroups(uid!, user.uid);
    }
  }

  Future<void> sendFriendRequest(String userID) async{
    if(!friends.contains(userID)) {
      await userService.requestFriend(userID, uid!);

      String notificationId = uuid.v1();
      model.Notification notification = model.Notification(
          notificationId: notificationId,
          type: 0,
          created: DateTime.now(),
          uid: userID,
          isRead: false,
          userId: uid!,
          eventId: '');

      await notificationService.saveNotification(notification);
      await userService.addNotification(userID, notificationId);
    }
  }

  Future<void> removeRequest(UserData user) async{
    if(requests.contains(user.uid)) {
      await userService.deleteRequest(uid!, user.uid);
    }
  }

  ///Deletes all user data from database and FirebaseAuthentication
  Future<void> deleteAccount() async{
    getUserDataStream?.cancel();
    ///Remove user from friends and pending requests
    userService.removeUserFromUserData(uid!);
    ///Remove user from other user's groups and delete user groups
    groupService.removeUserFromAllGroups(uid!);
    groupService.deleteAllUserGroups(uid!);
    ///Delete all chats that include user
    chatService.deleteAllUserChats(uid!);
    ///Delete all notifications that mention user events and user, and user notifications
    if(events.isNotEmpty){
      notificationService.deleteNotificationsForEvents(events);
    }
    notificationService.deleteNotificationsMentioning(uid!);
    notificationService.deleteNotificationsForUser(uid!);
    ///Delete user from event participants, requests, and sharedWith and delete all user events
    eventService.removeUserFromEvents(uid!);
    eventService.deleteAllUserEvents(uid!);
    ///Delete all user locations
    locationService.deleteLocationsForUser(uid!);
    ///Delete username
    usernameService.deleteUsername(username!);
    ///Delete userData
    userService.deleteUserData(uid!);
    ///Delete user from FirebaseAuth
    await FirebaseAuth.instance.currentUser?.delete();
  }
}