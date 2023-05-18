import 'dart:async';
import 'dart:typed_data';
import 'dart:math' show cos, sqrt, asin;


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import 'package:wya_final/src/managers/chat_manager.dart';
import 'package:wya_final/src/managers/event_manager.dart';
import 'package:wya_final/src/managers/group_manager.dart';
import 'package:wya_final/src/managers/image_manager.dart';
import 'package:wya_final/src/managers/location_manager.dart';
import 'package:wya_final/src/managers/notification_manager.dart';
import 'package:wya_final/src/managers/user_manager.dart';
import 'package:wya_final/src/managers/username_manager.dart';
import 'package:wya_final/src/models/location.dart';
import 'package:wya_final/src/models/shared_event.dart';
import 'package:wya_final/src/utils/location_provider.dart';
import 'package:wya_final/src/models/user_data.dart';
import 'src/models/notification_info.dart';
import 'src/models/chat_info.dart';
import 'src/models/notification.dart' as model;
import 'package:wya_final/src/models/chat.dart' as model;
import 'package:wya_final/src/models/message.dart' as model;
import 'package:username_gen/username_gen.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'src/models/event.dart';
import 'src/models/group.dart';
import 'src/models/match.dart' as model;
import 'firebase_options.dart';                       // new

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  DateTime _selectedDay = DateTime.now();
  DateTime get selectedDay => _selectedDay;
  DateTime _endDay = DateTime.now();
  DateTime get endDay => _endDay;
  set selectedDay(DateTime selectedDay){
    _selectedDay = selectedDay;
    _endDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 23, 59);
    notifyListeners();
  }

  final LocationProvider _locationProvider = LocationProvider();
  Future<LocationProvider> get location async {
    await _locationProvider.getCurrentLocation();
    return _locationProvider;
  }

  StreamSubscription<DocumentSnapshot>? _userDataSubscription;
  UserData _userData = UserData.emptyUserData();
  UserData get userData => _userData;

  StreamSubscription<QuerySnapshot>? _friendSubscription;
  List<UserData> _friends = [];
  List<UserData> get friends => _friends;
  set friends(List<UserData> newFriends){
    _friends = newFriends;
    notifyListeners();
  }

  Map<String, UserData> _friendMap = <String, UserData>{};
  Map<String, UserData> get friendMap => _friendMap;
  set friendMap(Map<String, UserData> newFriendMap){
    _friendMap = newFriendMap;
  }

  StreamSubscription<QuerySnapshot>? _requestSubscription;
  List<UserData> _requests = [];
  List<UserData> get requests => _requests;
  set requests(List<UserData> newRequests){
    _requests = newRequests;
    notifyListeners();
  }

  StreamSubscription<QuerySnapshot>? _groupSubscription;
  Map<Group, List<UserData>> _groups = {};
  Map<Group, List<UserData>> get groups => _groups;
  set groups(Map<Group, List<UserData>> newGroups){
    _groups = newGroups;
    notifyListeners();
  }

  StreamSubscription<QuerySnapshot>? _eventSubscription;
  Map<DateTime, List<Event>> _events = {};
  Map<DateTime, List<Event>> get events => _events;
  List<Event> get selectedEvents {
    DateTime dayOfEvent = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 0,0);
    return _events[dayOfEvent] ?? [];
  }

  Event? _selectedEvent;
  Event? get selectedEvent => _selectedEvent;
  set selectedEvent(Event? event){
    _selectedEvent = event;
  }

  StreamSubscription<QuerySnapshot>? _sharedEventSubscription;
  Map<DateTime, List<SharedEvent>> _sharedEvents = {};
  Map<DateTime, List<SharedEvent>> get sharedEvents => _sharedEvents;
  List<SharedEvent> get selectedSharedEvents {
    DateTime dayOfEvent = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 0,0);
    return _sharedEvents[dayOfEvent] ?? [];
  }
  Map<DateTime, List<model.Match>> _matches = {};
  Map<DateTime, List<model.Match>> get matches => _matches;
  List<model.Match> get selectedMatches {
    DateTime dayOfEvent = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 0,0);
    return _matches[dayOfEvent] ?? [];
  }

  SharedEvent? _selectedSharedEvent;
  SharedEvent? get selectedSharedEvent => _selectedSharedEvent;
  set selectedSharedEvent(SharedEvent? event){
    _selectedSharedEvent = event;
  }

  Map<DateTime, List<SharedEvent>> _joinedEvents = {};
  Map<DateTime, List<SharedEvent>> get joinedEvents => _joinedEvents;
  List<SharedEvent> get selectedJoinedEvents {
    DateTime dayOfEvent = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 0,0);
    return _joinedEvents[dayOfEvent] ?? [];
  }

  StreamSubscription<QuerySnapshot>? _chatSubscription;
  List<ChatInfo> _chats = [];
  List<ChatInfo> get chats => _chats;
  set chats(List<ChatInfo> newChats){
    _chats = newChats;
    notifyListeners();
  }

  StreamSubscription<QuerySnapshot>? _notificationSubscription;
  Map<DateTime, List<NotificationInfo>> _notifications = {};
  Map<DateTime, List<NotificationInfo>> get notifications => _notifications;

  int get unreadNotifications{
    int unread = 0;
    for(MapEntry entry in _notifications.entries){
      for(NotificationInfo n in entry.value){
        if(!n.notification.isRead){
          unread++;
        }
      }
    }
    return unread;
  }
  int get unreadMessages{
    int unread = 0;
    for(ChatInfo chat in _chats){
      for(model.Message m in chat.messages){
        if(m.senderId != userData.uid && !m.isRead){
          unread++;
        }
      }
    }
    return unread;
  }

  ChatInfo? _selectedChat;
  ChatInfo? get selectedChat => _selectedChat;
  set selectedChat(ChatInfo? newSelectedChat){
    _selectedChat = newSelectedChat;
    notifyListeners();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
      GoogleProvider(clientId: '536153952717-slhgpkmab3a5i2rd1ahe68n3jnc1pgpk.apps.googleusercontent.com'),
    ]);

    _endDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 23, 59);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;

        _userDataSubscription = FirebaseFirestore.instance
            .collection('userData')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots()
            .listen((snapshot) {
          if(snapshot.data() != null){
            print('getting user data');
            _userData = UserData.fromSnap(snapshot);
            notifyListeners();

            ///REQUESTS
            if(userData.requests.isEmpty){
              print('requests is empty');
              _requests = [];
              print('REQUESTS IS EMPTY AGAIN: ${_requests.length}');
              notifyListeners();
            } else {
              print('requests IS NOT EMPTY');
              _requestSubscription =
                  FirebaseFirestore.instance
                      .collection('userData')
                      .where('uid', whereIn: userData.requests)
                      .snapshots()
                      .listen((snapshot) {
                    _requests = [];
                    for (final document in snapshot.docs) {
                      UserData requestingUser = UserData.fromSnap(document);
                      _requests.add(requestingUser);
                    }
                    notifyListeners();
                  });
            }

            ///EVENTS
            if(userData.events.isEmpty) {
              _events = {};
              notifyListeners();
              print("events is empty");
            }else{
              print("events is not empty");
              _eventSubscription = FirebaseFirestore.instance
                  .collection('events')
                  .where('uid', isEqualTo: userData.uid)
                  .orderBy('startsAt')
                  .snapshots()
                  .listen((snapshot) {
                _events = {};
                for(final document in snapshot.docs){
                  Event event = Event.fromSnap(document);
                  DateTime startsAt = event.startsAt as DateTime;
                  DateTime dayOfEvent = DateTime(startsAt.year, startsAt.month, startsAt.day, 0,0);

                  if(_selectedEvent != null && _selectedEvent!.eventId == event.eventId){
                    _selectedEvent = event;
                  }

                  if(!_events.containsKey(dayOfEvent)){
                    _events.putIfAbsent(dayOfEvent, () => [event]);
                  }else{
                    _events[dayOfEvent]!.add(event);
                  }
                }
                notifyListeners();
              });
            }

            ///FRIENDS
            if(userData.friends.isEmpty) {
              print("friends is empty");
              _friends = [];
              _friendMap = {};
              notifyListeners();
            }else{
              print("friends is not empty");
              _friendSubscription = FirebaseFirestore.instance
                  .collection('userData')
                  .where('uid', whereIn: userData.friends)
                  .snapshots()
                  .listen((snapshot){
                _friends = [];
                _friendMap = {};
                for(final document in snapshot.docs){
                  UserData friend = UserData.fromSnap(document);
                  _friendMap.putIfAbsent(friend.uid, () => friend);
                  _friends.add(friend);
                }
                notifyListeners();
              });
              if(userData.groups.isEmpty) {
                print('groups is empty');
                _groups = {};
                notifyListeners();
              }else{
                print("groups is not empty");
                _groupSubscription = FirebaseFirestore.instance
                    .collection('groups')
                    .where('groupId', whereIn: userData.groups)
                    .snapshots()
                    .listen((snapshot){
                  _groups = {};
                  for(final document in snapshot.docs){
                    Group group = Group.fromSnap(document);
                    List<UserData> members = friends.where((element) => group.members.contains(element.uid)).toList();
                    _groups.putIfAbsent(group, () => members);
                  }
                  notifyListeners();
                });
              }

              var sharedEventsRef = FirebaseFirestore.instance
                  .collection('events')
                  .orderBy('startsAt')
                  .where('sharedWith', arrayContains: user.uid)
                  .where('startsAt', isGreaterThanOrEqualTo: Timestamp.fromDate(_selectedDay));

              _sharedEventSubscription = sharedEventsRef
                  .snapshots()
                  .listen((snapshot) async {
                _sharedEvents = {};
                _matches = {};
                for (final document in snapshot.docs) {
                  Event event = Event.fromSnap(document);
                  DateTime startsAt = event.startsAt as DateTime;
                  DateTime dayOfEvent = DateTime(startsAt.year, startsAt.month, startsAt.day, 0,0);

                  if(_selectedSharedEvent != null && _selectedSharedEvent!.event.eventId == event.eventId){
                    _selectedSharedEvent = SharedEvent(event, _friendMap[document.data()['uid']]!);
                  }

                  if(event.participants.contains(userData.uid)){
                    if(!_joinedEvents.containsKey(dayOfEvent)){
                      print('joined events does not contain key for day ${dayOfEvent.toString()}');
                      _joinedEvents.putIfAbsent(dayOfEvent, () => [SharedEvent(event, _friendMap[event.uid]!)]);
                    }else{
                      print('joined events contains key for day ${dayOfEvent.toString()}');
                      _joinedEvents[dayOfEvent]!.add(SharedEvent(event, _friendMap[event.uid]!));
                    }
                  }

                  if(!_sharedEvents.containsKey(dayOfEvent)){
                    _sharedEvents.putIfAbsent(dayOfEvent, () => [SharedEvent(event, _friendMap[document.data()['uid']]!)]);
                  }else{
                    _sharedEvents[dayOfEvent]!.add(SharedEvent(event, _friendMap[document.data()['uid']]!));
                  }

                  model.Match? match = await isThereMatch(SharedEvent(event, _friendMap[document.data()['uid']]!));

                  if(match != null){
                    if(!_matches.containsKey(dayOfEvent)){
                      _matches.putIfAbsent(dayOfEvent, () => [match]);
                    }else{
                      _matches[dayOfEvent]!.add(match);
                    }
                  }
                }
                notifyListeners();
              });
            }
            if(userData.notifications.isEmpty){
              print('notifications is empty');
              _notifications = {};
              notifyListeners();
            }else{
              _notificationSubscription =
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .orderBy('created', descending: true)
                      .where('uid', isEqualTo: userData.uid)
                      .snapshots()
                      .listen((snapshot) async{
                    _notifications = {};
                    for(final document in snapshot.docs) {
                      model.Notification notification = model.Notification.fromSnap(document);
                      UserData user = UserData.fromSnap(await FirebaseFirestore.instance.collection('userData').doc(notification.userId).get());

                      NotificationInfo notInfo = NotificationInfo(notification: notification, user: user, event: null);

                      if(notification.type != 0 && notification.type != 1){
                        Event event = Event.fromSnap(await FirebaseFirestore.instance.collection('events').doc(notification.eventId).get());
                        notInfo = NotificationInfo(notification: notification, user: user, event: event);
                      }
                      DateTime dayOfNotification = DateTime(notification.created.year, notification.created.month, notification.created.day, 0, 0);

                      if(!_notifications.containsKey(dayOfNotification)){
                        _notifications.putIfAbsent(dayOfNotification, () => [notInfo]);
                      }else{
                        _notifications[dayOfNotification]!.add(notInfo);
                      }
                    }
                    notifyListeners();
                  });
            }
            if(userData.chats.isEmpty){
              print('chats is empty');
              _chats = [];
              notifyListeners();
            }else{
              print('chats is not empty');
              _chats = [];
              notifyListeners();
              _chatSubscription = FirebaseFirestore.instance
                  .collection('chats')
                  .where('chatId', whereIn: userData.chats)
                  .orderBy('lastMessageSentAt', descending: true)
                  .snapshots()
                  .listen((snapshot) async {
                _chats = [];
                _chats.clear();
                notifyListeners();
                for(final document in snapshot.docs){
                  model.Chat chat = model.Chat.fromSnap(document);
                  if(chat.messages.isNotEmpty){
                    List<model.Message> messages = [];
                    QuerySnapshot mess = await FirebaseFirestore.instance
                        .collection('messages').where('chatId', isEqualTo: chat.chatId)
                        .get();
                    for(final message in mess.docs){
                      model.Message m = model.Message.fromSnap(message);
                      messages.add(m);
                    }
                    UserData friend = UserData.emptyUserData();
                    if(chat.uid1 == userData.uid){
                      if(friendMap.containsKey(chat.uid2)){
                        friend = _friendMap[chat.uid2]!;
                      }else{
                        friend = UserData.fromSnap(await FirebaseFirestore.instance.
                        collection('userData').doc(chat.uid2).get());
                      }
                    }else{
                      if(friendMap.containsKey(chat.uid1)){
                        friend = _friendMap[chat.uid1]!;
                      }else{
                        friend = UserData.fromSnap(await FirebaseFirestore.instance.
                        collection('userData').doc(chat.uid1).get());
                      }
                    }
                    ChatInfo chatInfo = ChatInfo(chat: chat, messages: messages, user: friend);
                    if(_chats.any((element) => element.chat.chatId == chatInfo.chat.chatId)){
                      _chats[_chats.indexWhere((element) => element.chat.chatId == chatInfo.chat.chatId)] =
                          chatInfo;
                      if(_selectedChat != null){
                        if(_selectedChat!.chat.chatId == chatInfo.chat.chatId){
                          _selectedChat = chatInfo;
                        }
                      }
                    }else{
                      _chats.add(chatInfo);
                    }
                  }
                }
                notifyListeners();
              });
            }

          }else{
            print('creating user data');
            String randomUsername = '';
            //bool uniqueUsername = false;
            randomUsername = UsernameGen().generate();
            //uniqueUsername = await usernameIsUnique(randomUsername);
            //}
            UserData data = UserData(
                email: user.email ?? '',
                name: user.displayName ?? '',
                friends: [],
                requests: [],
                events: [],
                groups: [],
                notifications: [],
                photoUrl: 'https://picsum.photos/250?image=9',
                uid: user.uid,
                username: randomUsername,
                allowAdd: true,
                maxMatchDistance: 100,
                chats: []
            );
            FirebaseFirestore.instance
                .collection('usernames')
                .doc(randomUsername)
                .set({"username": randomUsername});
            FirebaseFirestore.instance
                .collection('userData')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .set(data.toJson());
          }
          notifyListeners();
        });


      } else {
        _loggedIn = false;
        _userDataSubscription?.cancel();
        _friendSubscription?.cancel();
        _sharedEventSubscription?.cancel();
        _requestSubscription?.cancel();
        _eventSubscription?.cancel();
        _groupSubscription?.cancel();
        _notificationSubscription?.cancel();
        _chatSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  Future<void> startChatWith(UserData friend) async{
    bool foundChat = false;
    for(ChatInfo chat in _chats){
      if(chat.user.uid == friend.uid){
        foundChat = true;
        _selectedChat = chat;
      }
    }

    if(!foundChat) {
      model.Chat newChat = model.Chat(chatId: const Uuid().v1(),
          uid1: userData.uid,
          uid2: friend.uid,
          messages: [],
          lastMessage: null,
          lastMessageSentAt: null);
      await FirebaseFirestore.instance.collection('chats')
          .doc(newChat.chatId)
          .set(newChat.toJson());
      await FirebaseFirestore.instance.collection('userData')
          .doc(userData.uid)
          .update({
        'chats': FieldValue.arrayUnion([newChat.chatId])});
      await FirebaseFirestore.instance.collection('userData')
          .doc(friend.uid)
          .update({
        'chats': FieldValue.arrayUnion([newChat.chatId])});

      selectedChat = ChatInfo(chat: newChat, messages: [], user: friend);
    }
  }

  Future<void> setReadMessages() async{
    QuerySnapshot mess = await FirebaseFirestore.instance
        .collection('messages').where('chatId', isEqualTo: _selectedChat!.chat.chatId)
        .where('senderId', isNotEqualTo: userData.uid)
        .get();
    for(final message in mess.docs){
      await FirebaseFirestore.instance.collection('messages').doc((message.data() as Map<String, dynamic>)['messageId']).update({'isRead' : true});
    }
  }

  Future<void> setReadNotifications() async{
    QuerySnapshot nots = await FirebaseFirestore.instance
        .collection('notifications').where('uid', isEqualTo: userData.uid)
        .where('isRead', isEqualTo: false)
        .get();
    for(final not in nots.docs){
      await FirebaseFirestore.instance.collection('notifications').doc((not.data() as Map<String, dynamic>)['notificationId']).update({'isRead' : true});
    }
  }

  void handleNewMessage(types.PartialText message) {
    model.Message newMessage = model.Message(messageId: const Uuid().v1(), senderId: userData.uid,
        chatId: selectedChat!.chat.chatId, text: message.text, dateSent: DateTime.now(), isRead: false);
    _selectedChat!.messages.insert(_selectedChat!.messages.length, newMessage);
    FirebaseFirestore.instance.collection('messages').doc(newMessage.messageId).set(newMessage.toJson());
    FirebaseFirestore.instance.collection('chats').doc(newMessage.chatId).update({
      'messages': FieldValue.arrayUnion([newMessage.messageId]), 'lastMessageId' : newMessage.messageId, 'lastMessageSentAt' : newMessage.dateSent});

  }

  Future<model.Match?> isThereMatch(SharedEvent sharedEvent) async {
    model.Match? match;
    DateTime dayOfEvent = DateTime(sharedEvent.event.startsAt.year, sharedEvent.event.startsAt.month, sharedEvent.event.startsAt.day, 0,0);
    if(_events.containsKey(dayOfEvent)){
      for(Event event in _events[dayOfEvent]!){
        if(event.startsAt.isBefore(sharedEvent.event.endsAt) &&
            event.endsAt.isAfter(sharedEvent.event.startsAt)){
          Location locationEvent = Location.fromSnap(await FirebaseFirestore.instance.collection('locations').doc(event.locationId).get());
          Location locationSharedEvent = Location.fromSnap(await FirebaseFirestore.instance.collection('locations').doc(sharedEvent.event.locationId).get());
          double lat1 = locationEvent.latitude;
          double lon1 = locationEvent.longitude;
          double lat2 = locationSharedEvent.latitude;
          double lon2 = locationSharedEvent.longitude;
          double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
          double distance = distanceInMeters / 1000;
          print('distance: ${distance.toString()}km');
          if(distance <= userData.maxMatchDistance){
            match = model.Match(friendEvent: sharedEvent, userEvent: event);
            break;
          }
        }
      }
    }
    return match;
  }

  void changeAllowAdd(bool value){
    if(value != userData.allowAdd){
      FirebaseFirestore.instance
          .collection('userData')
          .doc(userData.uid)
          .update({
        'allowAdd': value
      });
    }
  }

  void changeMaxMatchDistance(double value){
    if(value.toInt() != userData.maxMatchDistance){
      FirebaseFirestore.instance
          .collection('userData')
          .doc(userData.uid)
          .update({
        'maxMatchDistance': value.toInt()
      });
    }
  }

  Future<void> changeProfilePicture(Uint8List file) async{
    String photoUrl =
    await uploadImageToStorage('profilePics', file, false);
    return FirebaseFirestore.instance.collection('userData').doc(userData.uid).update(
        {'photoUrl' : photoUrl});
  }

  Future<String> uploadImageToStorage(String childName, Uint8List file, bool isPost) async {
    // creating location to our firebase storage

    Reference ref =
    FirebaseStorage.instance.ref().child(childName).child(FirebaseAuth.instance.currentUser!.uid);
    if(isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    // putting in uint8list format -> Upload task like a future but not future
    UploadTask uploadTask = ref.putData(
        file
    );

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Event getEventById(String eventId){
    List<Event> matchingEvents = selectedEvents.where((element) => element.eventId == eventId).toList();
    return matchingEvents.first;
  }
  Future<Location?> getLocationById(String locationId) async{
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('locations').doc(locationId).get();
    return Location.fromSnap(snap);
  }

  ///Friend request methods
  Future<void> requestFriend(String uid) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('userData').doc(uid).get();
    List friends = (snap as dynamic)['friends'];

    if(!friends.contains(uid)) {

      String notificationId = Uuid().v1();
      model.Notification notification = model.Notification(notificationId:  notificationId, type: 0, created: DateTime.now(), uid: uid, isRead: false, userId: userData.uid, eventId: '');

      FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toJson());

      FirebaseFirestore.instance
          .collection('userData')
          .doc(uid)
          .update({
        'notifications': FieldValue.arrayUnion([notificationId])
      });

      FirebaseFirestore.instance
          .collection('userData')
          .doc(uid)
          .update({
        'requests': FieldValue.arrayUnion([userData.uid])
      });
    }
  }
  Future<void> deleteRequest(String uid) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    if(requests.contains(uid)) {
      FirebaseFirestore.instance
          .collection('userData')
          .doc(userData.uid)
          .update({
        'requests': FieldValue.arrayRemove([uid])
      });
    }
  }

  ///Friend methods
  Future<void> addFriend(String friendUID) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('userData').doc(friendUID).get();
    List friends = (snap as dynamic)['friends'];

    if(!friends.contains(userData.uid)) {

      String notificationId = Uuid().v1();
      model.Notification notification = model.Notification(notificationId:  notificationId, type: 1, created: DateTime.now(), uid: friendUID, isRead: false, userId: userData.uid, eventId: '');

      FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toJson());

      FirebaseFirestore.instance
          .collection('userData')
          .doc(friendUID)
          .update({
        'notifications': FieldValue.arrayUnion([notificationId])
      });

      FirebaseFirestore.instance
          .collection('userData')
          .doc(userData.uid)
          .update({
        'requests': FieldValue.arrayRemove([friendUID])
      });

      FirebaseFirestore.instance
          .collection('userData')
          .doc(friendUID)
          .update({
        'friends': FieldValue.arrayUnion([userData.uid])
      });

      FirebaseFirestore.instance
          .collection('userData')
          .doc(userData.uid)
          .update({
        'friends': FieldValue.arrayUnion([friendUID])
      });

    }
  }
  Future<void> removeFriend(String uid) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('userData').doc(uid).get();
    List friends = (snap as dynamic)['friends'];

    if(friends.contains(uid)) {
      FirebaseFirestore.instance
          .collection('userData')
          .doc(uid)
          .update({
        'friends': FieldValue.arrayRemove([userData.uid])
      });

      FirebaseFirestore.instance
          .collection('userData')
          .doc(userData.uid)
          .update({
        'friends': FieldValue.arrayRemove([uid])
      });
    }
  }

  ///Group methods
  Future<void> addGroup(Group group) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    await FirebaseFirestore.instance.collection('groups').doc(group.groupId).set(group.toJson());

    FirebaseFirestore.instance
        .collection('userData')
        .doc(userData.uid)
        .update({
      'groups': FieldValue.arrayUnion([group.groupId])
    });

  }
  Future<void> updateGroup(Group group) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    await FirebaseFirestore.instance.collection('groups').doc(group.groupId).update(group.toJson());
  }
  Future<void> deleteGroup(String groupId) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();

    FirebaseFirestore.instance
        .collection('userData')
        .doc(userData.uid)
        .update({
      'groups': FieldValue.arrayRemove([groupId])
    });
  }
  bool groupNameIsUnique(String groupName, String groupId){
    bool isUnique = false;
    FirebaseFirestore.instance
        .collection('groups')
        .where('groupId', whereIn: userData.groups)
        .where('groupId', isNotEqualTo: groupId)
        .where('name', isEqualTo: groupName)
        .snapshots()
        .listen((snapshot) {
      if(snapshot.docs.isNotEmpty){
        isUnique = false;
      }else{
        isUnique = true;
      }
    });
    return isUnique;
  }

  ///Event methods
  Future<void> addEvent(Event event, PickResult location) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    Location eventLocation = Location(
        locationId: const Uuid().v1(),
        uid: event.uid,
        formattedAddress: location.formattedAddress,
        url: location.url,
        latitude: location.geometry!.location.lat,
        longitude: location.geometry!.location.lng,);

    await FirebaseFirestore.instance.collection('locations').doc(eventLocation.locationId).set(eventLocation.toJson());

    event = Event(
        description: event.description,
        uid: event.uid,
        eventId: event.eventId,
        datePublished: DateTime.now(),
        startsAt: event.startsAt,
        endsAt: event.endsAt,
        participants: event.participants,
        locationId: eventLocation.locationId,
        sharedWithAll: event.sharedWithAll,
        isOpen: event.isOpen,
        groups: event.groups,
        category: event.category,
        sharedWith: event.sharedWith,
        requests: event.requests
    );

    if(event.sharedWithAll){
      List<String> newSharedWith = [];
      for(UserData friend in friends){
        newSharedWith.add(friend.uid);
      }
      event = Event(
          description: event.description,
          uid: event.uid,
          eventId: event.eventId,
          datePublished: event.datePublished,
          startsAt: event.startsAt,
          endsAt: event.endsAt,
          participants: event.participants,
          locationId: event.locationId,
          sharedWithAll: event.sharedWithAll,
          isOpen: event.isOpen,
          groups: event.groups,
          category: event.category,
          sharedWith: newSharedWith,
          requests: event.requests
      );
    }
    await FirebaseFirestore.instance.collection('events').doc(event.eventId).set(event.toJson());

    FirebaseFirestore.instance
        .collection('userData')
        .doc(userData.uid)
        .update({
      'events': FieldValue.arrayUnion([event.eventId])
    });
  }
  Future<void> updateEvent(Event event, PickResult location) async{
    Location? oldLocation = await getLocationById(event.locationId);
    if(oldLocation!.formattedAddress != location.formattedAddress){
      Location eventLocation = Location(
          locationId: const Uuid().v1(),
          uid: event.uid,
          formattedAddress: location.formattedAddress,
          url: location.url,
          latitude: location.geometry!.location.lat,
          longitude: location.geometry!.location.lng,
      );

      await FirebaseFirestore.instance.collection('locations').doc(eventLocation.locationId).set(eventLocation.toJson());

      event = Event(
          description: event.description,
          uid: event.uid,
          eventId: event.eventId,
          datePublished: DateTime.now(),
          startsAt: event.startsAt,
          endsAt: event.endsAt,
          participants: event.participants,
          locationId: eventLocation.locationId,
          sharedWithAll: event.sharedWithAll,
          isOpen: event.isOpen,
          groups: event.groups,
          category: event.category,
          sharedWith: event.sharedWith,
          requests: event.requests
      );
    }
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    await FirebaseFirestore.instance.collection('events').doc(event.eventId).update(event.toJson());
  }
  Future<void> deleteEvent(String eventId) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    await FirebaseFirestore.instance.collection('events').doc(eventId).delete();

    FirebaseFirestore.instance
        .collection('userData')
        .doc(userData.uid)
        .update({
      'events': FieldValue.arrayRemove([eventId])
    });
  }

  Future<void> requestToJoinEvent(String eventId) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();

    Event event = Event.fromSnap(doc);

    String notificationId = Uuid().v1();
    model.Notification notification = model.Notification(notificationId:  notificationId, type: 2, created: DateTime.now(), uid: event.uid, isRead: false, userId: userData.uid, eventId: eventId);

    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update({
      'requests': FieldValue.arrayUnion([userData.uid])
    });

    FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .set(notification.toJson());

    FirebaseFirestore.instance
        .collection('userData')
        .doc(event.uid)
        .update({
      'notifications': FieldValue.arrayUnion([notificationId])
    });
  }

  Future<void> acceptEventRequest(String eventId, String requesterUID) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();

    Event event = Event.fromSnap(doc);

    if(event.requests.contains(requesterUID)){

      ///Create notification letting requesting user know that their request has been accepted
      String notificationId = const Uuid().v1();
      model.Notification notification = model.Notification(notificationId: notificationId, type: 3, created: DateTime.now(), uid: requesterUID, isRead: false, userId: userData.uid, eventId: eventId);

      FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toJson());

      FirebaseFirestore.instance
          .collection('userData')
          .doc(requesterUID)
          .update({
        'notifications': FieldValue.arrayUnion([notificationId])
      });

    }
  }

  Future<void> joinEvent(String eventId) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();

    Event event = Event.fromSnap(doc);

    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update({
      'participants': FieldValue.arrayUnion([userData.uid])
    });

    String notificationId = Uuid().v1();
    model.Notification notification = model.Notification(notificationId: notificationId, type: 4, created: DateTime.now(), uid: event.uid, isRead: false, userId: userData.uid, eventId: eventId);

    FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .set(notification.toJson());

    FirebaseFirestore.instance
        .collection('userData')
        .doc(event.uid)
        .update({
      'notifications': FieldValue.arrayUnion([notificationId])
    });
  }

  Future<void> removeParticipant(String eventId, String uid) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('events').doc(eventId).get();

    Event event = Event.fromSnap(snapshot);

    if(event.participants.contains(uid)){
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .update({
        'participants': FieldValue.arrayRemove([uid])
      });
    }
  }

  ///User data methods
  Future<void> changeName(String name) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    return FirebaseFirestore.instance
        .collection('userData')
        .doc(userData.uid)
        .update({
      'name': name
    });
  }
  Future<void> changeUsername(String username) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    FirebaseFirestore.instance.collection('usernames').doc(userData.username).delete();
    FirebaseFirestore.instance.collection('usernames').doc(username).set({"username": username});
    return FirebaseFirestore.instance
        .collection('userData')
        .doc(userData.uid)
        .update({
      'username': username
    });
  }
  Future<void> changeEmail(String email) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    FirebaseAuth.instance.currentUser?.updateEmail(email);

    return FirebaseFirestore.instance
        .collection('userData')
        .doc(userData.uid)
        .update({
      'email': email
    });
  }
  Future<bool> usernameIsUnique(String username) async{
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('usernames')
        .doc(username).get();

    return !doc.exists;
  }

  Future<bool> emailIsUnique(String email) async{
    Query doc = await FirebaseFirestore.instance
        .collection('userData')
        .where('email', isEqualTo: email)
        .where('uid', isNotEqualTo: userData.uid);

    return doc.snapshots().isEmpty;
  }
}