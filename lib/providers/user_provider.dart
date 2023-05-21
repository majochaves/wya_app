import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wya_final/models/user_data.dart';
import 'package:username_gen/username_gen.dart';

import '../services/image_service.dart';
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
  var uuid = const Uuid();

  /// Provider values
  /* UserData model values*/
  String? _email;
  String? _uid;
  String? _photoUrl;
  String? _username;
  String? _name;
  bool? _allowAdd;
  int? _maxMatchDistance;
  List _friends = [];
  List _requests = [];
  List _groups = [];
  List _events = [];
  List _notifications = [];
  List _chats = [];

  /* Additional values*/
  UserData? currentUserData;
  List<UserData> friendInfo = [];
  List<UserData> requestInfo = [];

  ///Listens to changes in UserData from database and updates
  void init() {
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        userService.getUserData(user.uid)
            .listen((userData) {
        /*If there is existing user data for user*/
          if(userData != null) {
            currentUserData = userData;
            notifyListeners();
            /*Updates current user data model values*/
            email = userData.email;
            uid = userData.uid;
            photoUrl = userData.photoUrl;
            username = userData.username;
            name = userData.name;
            friends = userData.friends;
            requests = userData.requests;
            groups = userData.groups;
            events = userData.events;
            notifications = userData.notifications;
            chats = userData.chats;
            allowAdd = userData.allowAdd;
            maxMatchDistance = userData.maxMatchDistance;
            notifyListeners();

          /*Updates friendInfo*/
            if(friends.isNotEmpty){
              Stream<List<UserData>> friendStream = UserService().getFriends(friends);
              friendStream.listen((friends) {

                friendInfo = friends;
                notifyListeners();
              });
            }else{
              friendInfo = [];
              notifyListeners();
            }
          /*Updates requests*/
            if(requests.isNotEmpty){
              Stream<List<UserData>> friendStream = UserService().getFriends(requests);
              friendStream.listen((requests) {
                requestInfo = requests;
                notifyListeners();
              });
            }else{
              requestInfo = [];
              notifyListeners();
            }
        /*There is no existing user data for user*/
          }else{
            /*Generate new data for user and save it to database*/
            ///TODO: Verify random username doesn't exist
            String randomUsername = generateRandomUsername();

            email =  user.email ?? '';
            name = user.displayName ?? '';
            friends = [];
            requests = [];
            events = [];
            groups = [];
            notifications = [];
            photoUrl = 'https://picsum.photos/250?image=9';
            uid = user.uid;
            username = randomUsername;
            allowAdd = true;
            maxMatchDistance = 100;
            chats = [];
            saveData();
            notifyListeners();
          }
        });
      }
    });
  }

  ///User model values getters and setters
  String? get email => _email;
  set email(String? val){
    _email = val;
    notifyListeners();
  }
  String? get name => _name;
  set name(String? val){
    _name = val;
    notifyListeners();
  }
  String? get uid => _uid;
  set uid(String? val){
    _email = val;
    notifyListeners();
  }
  String? get photoUrl => _photoUrl;
  set photoUrl(String? val){
    _photoUrl = val;
    notifyListeners();
  }
  String? get username => _username;
  set username(String? val){
    _username = val;
    notifyListeners();
  }
  bool? get allowAdd => _allowAdd;
  set allowAdd(bool? val){
    _allowAdd = val;
    notifyListeners();
  }
  int? get maxMatchDistance => _maxMatchDistance;
  set maxMatchDistance(int? val){
    _maxMatchDistance = val;
    notifyListeners();
  }
  List get friends => _friends;
  set friends(List val){
    _friends = val;
    notifyListeners();
  }
  List get requests => _requests;
  set requests(List val){
    _requests = val;
    notifyListeners();
  }
  List get groups => _groups;
  set groups(List val){
    _groups = val;
    notifyListeners();
  }
  List get events => _events;
  set events(List val){
    _events = val;
    notifyListeners();
  }
  List get notifications => _notifications;
  set notifications(List val){
    _notifications = val;
    notifyListeners();
  }
  List get chats => _chats;
  set chats(List val){
    _chats = val;
    notifyListeners();
  }

  ///Provider methods
  Future<bool> emailIsUnique(String email) async{
    return userService.emailIsUnique(email, uid!);
  }

  Future<void> changeEmail(String val) async{
    _email = val;
    notifyListeners();
    await userService.changeEmail(val, uid!);
    await FirebaseAuth.instance.currentUser!.updateEmail(val);
  }

  String generateRandomUsername(){
    return UsernameGen().generate();
  }
  Future<void> changeName(String val) async{
    _email = val;
    notifyListeners();
    await userService.changeName(val, uid!);
    await FirebaseAuth.instance.currentUser!.updateDisplayName(val);
  }

  Future<void> changeProfilePicture(Uint8List file) async{
    String photoUrl = await imageService.uploadImageToStorage('profilePics', file, uid!);
    _photoUrl = photoUrl;
    notifyListeners();
    await userService.changeProfilePicture(photoUrl, uid!);
    await FirebaseAuth.instance.currentUser!.updatePhotoURL(photoUrl);
  }

  Future<bool> usernameIsUnique(String val) async{
    return usernameService.usernameIsUnique(val);
  }

  Future<void> changeUsername(String val) async{
    _username = val;
    notifyListeners();
    await userService.changeUsername(val, uid!);
  }

  Future<void> changeAllowAdd(bool val) async{
    _allowAdd = val;
    notifyListeners();
    await userService.changeAllowAdd(val, uid!);
  }

  Future<void> changeMaxMatchDistance(int val) async{
    _maxMatchDistance = val;
    notifyListeners();
    await userService.changeMaxMatchDistance(val.toDouble(), uid!);
  }

  Future<void> addFriend(String userID) async{
    _friends.add(userID);
    notifyListeners();
    if(!friends.contains(userID)){
      if(requests.contains(userID)){
        _requests.remove(userID);
        notifyListeners();
        await userService.deleteRequest(uid!, userID);
      }
      await userService.addFriend(uid!, userID);
      await userService.addFriend(userID, uid!);

      String notificationId = uuid.v1();
      model.Notification notification
        = model.Notification(
            notificationId:  notificationId,
            type: 1,
            created: DateTime.now(),
            uid: userID,
            isRead: false,
            userId: uid!,
            eventId: ''
        );

      await notificationService.saveNotification(notification);
      await userService.addNotification(userID, notificationId);
      notifyListeners();
    }
  }

  Future<void> removeFriend(String userID) async{
    _friends.remove(userID);
    notifyListeners();
    if(friends.contains(userID)) {
      await userService.removeFriend(uid!, userID);
      await userService.removeFriend(userID, uid!);
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

  Future<void> removeRequest(String userID) async{
    _requests.remove(userID);
    notifyListeners();
    if(requests.contains(userID)) {
      userService.deleteRequest(uid!, userID);
    }
  }
/*
  void addGroup(String group){
    _groups.add(group);
    notifyListeners();
  }
  void removeGroup(String group){
    _groups.remove(group);
    notifyListeners();
  }

  void addEvent(String event){
    _events.add(event);
    notifyListeners();
  }
  void removeEvent(String event){
    _events.remove(event);
    notifyListeners();
  }

  void addNotification(String val){
    _notifications.add(val);
    notifyListeners();
  }
  void removeNotification(String val){
    _notifications.remove(val);
    notifyListeners();
  }

  void addChat(String val){
    _chats.add(val);
    notifyListeners();
  }
  void removeChat(String val){
    _chats.remove(val);
    notifyListeners();
  }*/


  void saveData() {
    ///TODO VERIFY UNIQUENESS OF USERNAME
    usernameService.saveUsername(username!);
    var newUserData =
      UserData(
          name: name!,
          email: email!,
          photoUrl: photoUrl!,
          uid: uid!,
          username: username!,
          events: events,
          groups: groups,
          allowAdd: allowAdd!,
          maxMatchDistance: maxMatchDistance!,
          notifications: notifications,
          chats: chats,
          friends: friends,
          requests: requests);
    currentUserData = newUserData;
    userService.saveUserData(newUserData);
  }
}