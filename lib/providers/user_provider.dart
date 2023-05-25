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
  String? _uid;
  String? get uid => _uid;
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
    _uid = null;
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
        print('Getting user data stream for user: ${user.uid}');
        getUserDataStream = userService.getUserData(FirebaseAuth.instance.currentUser!.uid).listen((event) {
          userData = event;
          email = userData!.email;
          _uid = userData!.uid;
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
          print('got friend stream: ${friendInfo.toString()}');
          friendInfo = event;
          notifyListeners();
        });
        getRequestsStream = userService.getUserRequests(user.uid).listen((event) {
          print('got request stream: ${friendInfo.toString()}');
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
    return userService.emailIsUnique(email, _uid!);
  }

  Future<bool> usernameIsUnique(String val) async{
    return usernameService.usernameIsUnique(val);
  }

  /*Field update methods*/
  Future<void> changeEmail(String val) async{
    email = val;
    notifyListeners();
    await userService.changeEmail(val, _uid!);
    await FirebaseAuth.instance.currentUser!.updateEmail(val);
  }

  Future<void> changeName(String val) async{
    email = val;
    notifyListeners();
    await userService.changeName(val, _uid!);
    await FirebaseAuth.instance.currentUser!.updateDisplayName(val);
  }

  Future<void> changeProfilePicture(Uint8List file) async{
    String photoUrl = await imageService.uploadImageToStorage('profilePics', file, _uid!);
    photoUrl = photoUrl;
    notifyListeners();
    await userService.changeProfilePicture(photoUrl, _uid!);
    await FirebaseAuth.instance.currentUser!.updatePhotoURL(photoUrl);
  }

  Future<void> changeUsername(String val) async{
    await usernameService.deleteUsername(username!);
    await usernameService.saveUsername(val);
    username = val;
    notifyListeners();
    await userService.changeUsername(val, _uid!);
  }

  Future<void> changeAllowAdd(bool val) async{
    allowAdd = val;
    notifyListeners();
    await userService.changeAllowAdd(val, _uid!);
  }

  Future<void> changeMaxMatchDistance(int val) async{
    maxMatchDistance = val;
    notifyListeners();
    await userService.changeMaxMatchDistance(val.toDouble(), _uid!);
  }

  /*Friend and request methods*/
  Future<void> addFriend(String userId) async{
    if(!friends.contains(userId)){
      print('user: $uid ACCEPTING FRIEND REQUEST from user: ${userId}');
      await userService.addFriend(_uid!, userId);
      await userService.deleteRequest(_uid!, userId);

      String notificationId = uuid.v1();
      model.Notification notification
        = model.Notification(
            notificationId:  notificationId,
            type: 1,
            created: DateTime.now(),
            uid: userId,
            isRead: false,
            userId: _uid!,
            eventId: ''
        );

      notificationService.saveNotification(notification);
      userService.addNotification(userId, notificationId);
    }
  }

  Future<void> removeFriend(String userId) async{
    if(friends.contains(userId)) {
      print('user: $_uid REMOVING FRIEND ${userId}');
      await userService.removeFriend(_uid!, userId);
      eventService.removeFriendFromUserEvents(_uid!, userId);
      groupService.removeFriendFromUserGroups(_uid!, userId);
    }
  }

  Future<void> sendFriendRequest(String userID) async{
    if(!friends.contains(userID)) {
      print('user: $_uid SENDING FRIEND REQUEST TO user: $userID');
      await userService.requestFriend(userID, _uid!);

      String notificationId = uuid.v1();
      model.Notification notification = model.Notification(
          notificationId: notificationId,
          type: 0,
          created: DateTime.now(),
          uid: userID,
          isRead: false,
          userId: _uid!,
          eventId: '');

      await notificationService.saveNotification(notification);
      await userService.addNotification(userID, notificationId);
    }
  }

  Future<void> removeRequest(String userId) async{
    if(requests.contains(userId)) {
      print('user: $_uid REMOVING REQUEST FROM ${userId}');
      await userService.deleteRequest(_uid!, userId);
    }
  }

  ///Deletes all user data from database and FirebaseAuthentication
  Future<void> deleteAccount() async{
    getUserDataStream?.cancel();
    ///Remove user from friends and pending requests
    userService.removeUserFromUserData(_uid!);
    ///Remove user from other user's groups and delete user groups
    groupService.removeUserFromAllGroups(_uid!);
    groupService.deleteAllUserGroups(_uid!);
    ///Delete all chats that include user
    chatService.deleteAllUserChats(_uid!);
    ///Delete all notifications that mention user events and user, and user notifications
    if(events.isNotEmpty){
      notificationService.deleteNotificationsForEvents(events);
    }
    notificationService.deleteNotificationsMentioning(_uid!);
    notificationService.deleteNotificationsForUser(_uid!);
    ///Delete user from event participants, requests, and sharedWith and delete all user events
    eventService.removeUserFromEvents(_uid!);
    eventService.deleteAllUserEvents(_uid!);
    ///Delete all user locations
    locationService.deleteLocationsForUser(_uid!);
    ///Delete username
    usernameService.deleteUsername(username!);
    ///Delete userData
    userService.deleteUserData(_uid!);
    ///Delete user from FirebaseAuth
    await FirebaseAuth.instance.currentUser?.delete();
  }
}