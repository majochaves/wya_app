import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wya_final/models/user_data.dart';
import 'package:username_gen/username_gen.dart';

import '../services/event_service.dart';
import '../services/group_service.dart';
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
  final eventService = EventService();
  final groupService = GroupService();
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
  List requests = [];
  List groups = [];
  List events = [];
  List notifications = [];
  List chats = [];

  /* Additional values*/
  UserData? userData;
  List<UserData> friendInfo = [];
  List<UserData> requestInfo = [];

  StreamSubscription? getFriendsStream;
  StreamSubscription? getFriendInfoStream;
  StreamSubscription? getRequestsStream;
  StreamSubscription? getRequestInfoStream;

  bool isLoading = true;

  StreamSubscription<DocumentSnapshot>? _userDataSubscription;
  StreamSubscription<QuerySnapshot>? _friendSubscription;
  StreamSubscription<QuerySnapshot>? _requestSubscription;

  void cancelStreams(){
    _userDataSubscription?.cancel();
    _friendSubscription?.cancel();
    _requestSubscription?.cancel();
    getRequestsStream?.cancel();
    getRequestInfoStream?.cancel();
    getFriendsStream?.cancel();
    getFriendInfoStream?.cancel();
  }


  ///Listens to changes in UserData from database and updates
  void init() {
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _userDataSubscription = FirebaseFirestore.instance
            .collection('userData')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots()
            .listen((snapshot) async {
          if(snapshot.data() != null){
            print('getting user data');
            userData = UserData.fromSnap(snapshot);
            notifyListeners();
            /*Updates current user data model values*/
            email = userData!.email;
            uid = userData!.uid;
            photoUrl = userData!.photoUrl;
            username = userData!.username;
            name = userData!.name;
            friends = userData!.friends;
            requests = userData!.requests;
            groups = userData!.groups;
            events = userData!.events;
            notifications = userData!.notifications;
            chats = userData!.chats;
            allowAdd = userData!.allowAdd;
            maxMatchDistance = userData!.maxMatchDistance;
            isLoading = false;
            friendInfo = [];
            requestInfo = [];
            notifyListeners();
            if(friends.isNotEmpty){
              await FirebaseFirestore.instance
                  .collection('userData')
                  .where('uid', whereIn: friends)
                  .get().then((snapshot){
                for (final document in snapshot.docs) {
                  UserData friendUser = UserData.fromSnap(document);
                  if(!friendInfo.any((element) => element.uid == friendUser.uid)){
                    friendInfo.add(friendUser);
                  }
                  print('adding friend ${friendUser.name} to friendinfo. friendinfo length: ${friendInfo.length} ');
                }
              });
              notifyListeners();
            }
            if(requests.isNotEmpty){
              await FirebaseFirestore.instance
                  .collection('userData')
                  .where('uid', whereIn: requests)
                  .get().then((snapshot){
                for (final document in snapshot.docs) {
                  UserData requestingUser = UserData.fromSnap(document);
                  if(!requestInfo.any((element) => element.uid == requestingUser.uid)){
                    requestInfo.add(requestingUser);
                  }
                  print('adding request ${requestingUser.name} to requestinfo. requestinfo length: ${requestInfo.length} ');
                }
              });
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
      }else{
        _userDataSubscription?.cancel();
        _friendSubscription?.cancel();
        _requestSubscription?.cancel();
        getRequestsStream?.cancel();
        getRequestInfoStream?.cancel();
        getFriendsStream?.cancel();
        getFriendInfoStream?.cancel();
      }
    });
  }

  ///Provider methods
  Future<bool> emailIsUnique(String email) async{
    return userService.emailIsUnique(email, uid!);
  }

  Future<void> changeEmail(String val) async{
    email = val;
    notifyListeners();
    await userService.changeEmail(val, uid!);
    await FirebaseAuth.instance.currentUser!.updateEmail(val);
  }

  String generateRandomUsername(){
    return UsernameGen().generate();
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

  Future<bool> usernameIsUnique(String val) async{
    return usernameService.usernameIsUnique(val);
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

  Future<void> addFriend(UserData user) async{
    if(!friends.contains(user.uid)){

      _userDataSubscription?.pause();
      await userService.addFriend(uid!, user.uid);
      await userService.deleteRequest(uid!, user.uid);
      _userDataSubscription?.resume();

      userService.addFriend(user.uid, uid!);
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
      userService.removeFriend(user.uid, uid!);
      eventService.removeFriendFromUserEvents(uid!, user.uid);
      eventService.removeFriendFromUserEvents(user.uid!, uid!);
      groupService.removeFriendFromUserGroups(uid!, user.uid);
      groupService.removeFriendFromUserGroups(user.uid, uid!);
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
    userData = newUserData;
    userService.saveUserData(newUserData);
  }
}