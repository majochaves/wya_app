import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

import 'package:flutter/material.dart';
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
import 'firebase_options.dart';                    // new

class ApplicationState2 extends ChangeNotifier {
  ApplicationState2() {
    init();
  }

  final UserManager userManager = UserManager();
  final GroupManager groupManager = GroupManager();
  final EventManager eventManager = EventManager();
  final NotificationManager notificationManager = NotificationManager();
  final LocationManager locationManager = LocationManager();
  final ChatManager chatManager = ChatManager();
  final ImageManager imageManager = ImageManager();
  final UsernameManager usernameManager = UsernameManager();

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
            _userData = UserData.fromSnap(snapshot);
            notifyListeners();
            if(userData.requests.isEmpty){
              print('requests is empty');
              _requests = [];
              print(requests.toString());
              notifyListeners();
            } else {
              print('requests is not empty');
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
            if(userData.notifications.isEmpty){
              print('notifications is empty');
              _notifications = {};
              notifyListeners();
            }else{
              print('notifications is not empty');
              _notificationSubscription =
                  FirebaseFirestore.instance
                    .collection('notifications')
                    .orderBy('created', descending: true)
                    .where('uid', isEqualTo: userData.uid)
                    .snapshots()
                    .listen((snapshot) async {
                      _notifications = {};
                      for(final document in snapshot.docs) {
                        model.Notification notification = model.Notification.fromSnap(document);
                        UserData user = await userManager.getUserById(notification.userId);

                        NotificationInfo notInfo = NotificationInfo(notification: notification, user: user, event: null);

                        if(notification.type != 0 && notification.type != 1){
                          Event event = await eventManager.getEventById(notification.eventId);
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
            if(userData.friends.isEmpty) {
              print('friends is empty');
              _friends = [];
              _friendMap = {};
              print(friends.toString());
              notifyListeners();
            }else{
              print('friends is not empty');
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
                              friend = await userManager.getUserById(chat.uid2);
                            }
                          }else{
                            if(friendMap.containsKey(chat.uid1)){
                              friend = _friendMap[chat.uid1]!;
                            }else{
                              friend = await userManager.getUserById(chat.uid1);
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
              if(userData.groups.isEmpty) {
                print('groups is empty');
                _groups = {};
                notifyListeners();
              }else{
                print('groups is not empty');
                _groupSubscription = FirebaseFirestore.instance
                    .collection('groups')
                    .where('uid', isEqualTo: userData.uid)
                    .snapshots()
                    .listen((snapshot){
                  _groups = {};
                  for(final document in snapshot.docs){
                    Group group = Group.fromSnap(document);
                    List<UserData> members = friends.where((element) => group.members.contains(element.uid)).toList();
                    ///Check if group members have been removed from friends
                    bool ok = true;
                    List oldFriends = group.members.where((element) => !friends.contains(element)).toList();
                    if(oldFriends.isNotEmpty){
                      ///If group contains no active friends, delete group
                      if(group.members == oldFriends){
                        ok = false;
                        groupManager.deleteGroup(group.groupId);
                      }else{
                        ///If not, just remove old friends from group
                        groupManager.removeOldFriends(group.groupId, oldFriends);
                      }
                    }
                    if(ok){
                      _groups.putIfAbsent(group, () => members);
                    }
                  }
                  notifyListeners();
                });
              }

              if(userData.events.isEmpty) {
                print('events is empty');
                _events = {};
                notifyListeners();
              }else{
                print('events is not empty');
                _eventSubscription = FirebaseFirestore.instance
                    .collection('events')
                    .where('uid', isEqualTo: userData.uid)
                    .orderBy('startsAt')
                    .snapshots()
                    .listen((snapshot) async {
                  _events = {};
                  notifyListeners();
                  for(final document in snapshot.docs){
                    Event event = Event.fromSnap(document);
                    print('found event: ${event.eventId}');

                    DateTime startsAt = event.startsAt as DateTime;
                    DateTime dayOfEvent = DateTime(startsAt.year, startsAt.month, startsAt.day, 0,0);

                    if(_selectedEvent != null && _selectedEvent!.eventId == event.eventId){
                      print('found current selected event');
                      _selectedEvent = event;
                    }
                    if(!_events.containsKey(dayOfEvent)){
                      print('Event map does not contain key for ${dayOfEvent.toString()}. Adding new entry with event');
                      _events.putIfAbsent(dayOfEvent, () => [event]);
                    }else{
                      print('Event map contains key for ${dayOfEvent.toString()}. Adding event to list.');
                      _events[dayOfEvent]!.add(event);
                    }
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
                      .listen((snapshot) {
                      _sharedEvents = {};
                      _matches = {};
                      for (final document in snapshot.docs) {
                        Event event = Event.fromSnap(document);
                        DateTime startsAt = event.startsAt as DateTime;
                        DateTime dayOfEvent = DateTime(startsAt.year, startsAt.month, startsAt.day, 0,0);

                        if(_selectedSharedEvent != null){
                          if(_selectedSharedEvent!.event.eventId == event.eventId){
                            _selectedSharedEvent = SharedEvent(event, _friendMap[event.uid]!);
                          }
                        }
                        print('found event that user has joined: ');
                        if(event.participants.contains(userData.uid)){
                          if(!_joinedEvents.containsKey(dayOfEvent)){
                            print('joined events does not contain key for day ${dayOfEvent.toString()}');
                            _joinedEvents.putIfAbsent(dayOfEvent, () => [SharedEvent(event, _friendMap[event.uid]!)]);
                          }else{
                            print('joined events contains key for day ${dayOfEvent.toString()}');
                            _joinedEvents[dayOfEvent]!.add(SharedEvent(event, _friendMap[event.uid]!));
                          }
                        }

                        model.Match? match = isThereMatch(SharedEvent(event, _friendMap[event.uid]!));

                        if(!_sharedEvents.containsKey(dayOfEvent)){
                          _sharedEvents.putIfAbsent(dayOfEvent, () => [SharedEvent(event, _friendMap[event.uid]!)]);
                        }else{
                          _sharedEvents[dayOfEvent]!.add(SharedEvent(event, _friendMap[event.uid]!));
                        }

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

          }else{
            String randomUsername = '';
            randomUsername = UsernameGen().generate();
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
            usernameManager.addUsername(randomUsername);
            userManager.createUserData(data);
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

  ///USER DATA METHODS
  Future<void> changeAllowAdd(bool value) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    if(value != userData.allowAdd){
      await userManager.changeAllowAdd(value, userData.uid);
    }
  }

  Future<void> changeMaxMatchDistance(double value) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    if(value.toInt() != userData.maxMatchDistance){
      await userManager.changeMaxMatchDistance(value, userData.uid);
    }
  }

  Future<void> changeProfilePicture(Uint8List file) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    ///Upload image to storage
    String photoUrl = await imageManager.uploadImageToStorage('profilePics', file, false, userData.uid);
    ///Change user profile picture
    await userManager.changeProfilePicture(photoUrl, userData.uid);
  }

  Future<void> changeName(String name) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    await userManager.changeName(name, userData.uid);
  }

  Future<void> changeUsername(String username) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    usernameManager.deleteUsername(userData.username);
    usernameManager.addUsername(username);
    userManager.changeUsername(username, userData.uid);
  }

  Future<void> changeEmail(String email) async {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    FirebaseAuth.instance.currentUser?.updateEmail(email);
    userManager.changeEmail(email, userData.uid);
  }
  Future<bool> usernameIsUnique(String username) async{
    return usernameManager.usernameIsUnique(username);
  }

  Future<bool> emailIsUnique(String email) async{
    return userManager.emailIsUnique(email, userData.uid);
  }

  Future<void> requestFriend(String uid) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    if(!userData.friends.contains(uid)) {
      ///Add request
      await userManager.requestFriend(uid, userData.uid);

      ///Create notification
      String notificationId = const Uuid().v1();
      model.Notification notification = model.Notification(notificationId:  notificationId, type: 0, created: DateTime.now(), uid: uid, isRead: false, userId: userData.uid, eventId: '');

      await notificationManager.addNotification(notification);
      await userManager.addNotification(uid, notificationId);
    }
  }
  Future<void> deleteRequest(String uid) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    if(userData.requests.contains(uid)) {
      await userManager.deleteRequest(userData.uid, uid);
    }
  }

  Future<void> addFriend(String friendUID) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    if(!userData.friends.contains(friendUID)) {
      ///Delete request from requests
      if(userData.requests.contains(friendUID)){
        await userManager.deleteRequest(userData.uid, friendUID);
        notifyListeners();
      }

      ///Add friend to both friend lists.
      await userManager.addFriend(userData.uid, friendUID);
      await userManager.addFriend(friendUID, userData.uid);

      ///Send notification to friend that his request has been accepted.
      String notificationId = const Uuid().v1();
      model.Notification notification = model.Notification(notificationId:  notificationId, type: 1, created: DateTime.now(), uid: friendUID, isRead: false, userId: userData.uid, eventId: '');

      await notificationManager.addNotification(notification);
      await userManager.addNotification(friendUID, notificationId);
    }
  }

  Future<void> removeFriend(String friendUID) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    ///Remove friend from both friend lists and events that they are shared with
    if(userData.friends.contains(friendUID)) {
      await eventManager.removeFriendFromUserEvents(userData.uid, friendUID);
      await userManager.removeFriend(userData.uid, friendUID);
      await eventManager.removeFriendFromUserEvents(friendUID, userData.uid);
      await userManager.removeFriend(friendUID, userData.uid);
    }

    ///TO-DO. UPDATE GROUPS FOR BOTH
  }

  ///GROUP METHODS
  Future<void> addGroup(Group group) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    await groupManager.addGroup(group);
    await userManager.addGroup(userData.uid, group.groupId);
  }

  Future<void> updateGroup(Group group) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    await groupManager.updateGroup(group);
  }

  Future<void> deleteGroup(String groupId) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    await groupManager.deleteGroup(groupId);
    await userManager.deleteGroup(userData.uid, groupId);
  }

  bool groupNameIsUnique(String groupName, String groupId){
    return groupManager.groupNameIsUnique(userData.uid, groupName, groupId);
  }

  ///CHAT METHODS
  Future<void> startChatWith(UserData friend) async{
    ///Search if there is an existing chat with that friend
    bool foundChat = false;
    for(ChatInfo chat in _chats){
      if(chat.user.uid == friend.uid){
        foundChat = true;
        _selectedChat = chat;
      }
    }

    ///If there isn't, create one
    if(!foundChat) {
      model.Chat newChat = model.Chat(chatId: const Uuid().v1(),
          uid1: userData.uid,
          uid2: friend.uid,
          messages: [],
          lastMessage: null,
          lastMessageSentAt: null);
      await chatManager.createChat(newChat);
      await userManager.addChat(userData.uid, newChat.chatId);
      await userManager.addChat(friend.uid, newChat.chatId);

      selectedChat = ChatInfo(chat: newChat, messages: [], user: friend);
    }
  }

  Future<void> setReadMessages() async{
    chatManager.setReadMessages(_selectedChat!.chat.chatId, userData.uid);
  }

  Future<void> setReadNotifications() async{
    notificationManager.setReadNotifications(userData.uid);
  }

  void handleNewMessage(types.PartialText message) {
    model.Message newMessage = model.Message(messageId: const Uuid().v1(), senderId: userData.uid,
        chatId: selectedChat!.chat.chatId, text: message.text, dateSent: DateTime.now(), isRead: false);
    _selectedChat!.messages.insert(_selectedChat!.messages.length, newMessage);
    chatManager.addNewMessageToChat(newMessage);
  }

  ///EVENT METHODS
  Future<Location?> getLocationById(String locationId){
    return locationManager.getLocationById(locationId);
  }

  Future<void> addEvent(Event event, PickResult location) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    ///Create location
    Location eventLocation = Location(
        locationId: const Uuid().v1(),
        uid: event.uid,
        formattedAddress: location.formattedAddress,
        url: location.url,
        latitude: location.geometry!.location.lat,
        longitude: location.geometry!.location.lng,);
    await locationManager.createLocation(eventLocation);

    ///Update event fields
    List newSharedWith = event.sharedWith;
    if(event.sharedWithAll) {
      newSharedWith = [];
      for (UserData friend in friends) {
        newSharedWith.add(friend.uid);
      }
    }
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
        sharedWith: newSharedWith,
        requests: event.requests
    );

    ///Add event to database
    await eventManager.addEvent(event);
    await userManager.addEvent(userData.uid, event.eventId);
  }
  Future<void> updateEvent(Event event, PickResult location) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    ///Check if location has been changed
    Location? oldLocation = await locationManager.getLocationById(event.locationId);
    if(oldLocation!.formattedAddress != location.formattedAddress){
      ///If it has, add new location to database and update event information
      Location eventLocation = Location(
          locationId: const Uuid().v1(),
          uid: event.uid,
          formattedAddress: location.formattedAddress,
          url: location.url,
          latitude: location.geometry!.location.lat,
          longitude: location.geometry!.location.lng,);

      await locationManager.createLocation(eventLocation);
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

    await eventManager.updateEvent(event);
  }

  Future<void> deleteEvent(String eventId) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    await eventManager.deleteEvent(eventId);
    await userManager.deleteEvent(userData.uid, eventId);
  }

  Future<void> requestToJoinEvent(String eventId) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    Event event = await eventManager.getEventById(eventId);

    await eventManager.requestToJoinEvent(eventId, userData.uid);

    ///Create notification to event creator that user has requested to join their event
    String notificationId = const Uuid().v1();
    model.Notification notification = model.Notification(notificationId:  notificationId, type: 2, created: DateTime.now(), uid: event.uid, isRead: false, userId: userData.uid, eventId: eventId);

    await notificationManager.addNotification(notification);
    await userManager.addNotification(event.uid, notificationId);
  }

  Future<void> acceptEventRequest(String eventId, String requesterUID) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    Event event = await eventManager.getEventById(eventId);

    if(event.requests.contains(requesterUID)){
      await eventManager.acceptEventRequest(eventId, requesterUID);

      ///Create notification letting requesting user know that their request has been accepted
      String notificationId = const Uuid().v1();
      model.Notification notification = model.Notification(notificationId: notificationId, type: 3, created: DateTime.now(), uid: requesterUID, isRead: false, userId: userData.uid, eventId: eventId);

      await notificationManager.addNotification(notification);
      await userManager.addNotification(requesterUID, notificationId);
    }

  }

  Future<void> joinEvent(String eventId) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    Event event = await eventManager.getEventById(eventId);
    await eventManager.joinEvent(eventId, userData.uid);

    String notificationId = const Uuid().v1();
    model.Notification notification = model.Notification(notificationId: notificationId, type: 4, created: DateTime.now(), uid: event.uid, isRead: false, userId: userData.uid, eventId: eventId);

    ///Create notification to let event creator know that user joined their event
    await notificationManager.addNotification(notification);
    await userManager.addNotification(event.uid, notificationId);
  }

  Future<void> removeParticipant(String eventId, String uid) async{
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    Event event = await eventManager.getEventById(eventId);
    if(event.participants.contains(uid)){
      await eventManager.removeParticipant(eventId, uid);
    }
  }

  model.Match? isThereMatch(SharedEvent sharedEvent){
    model.Match? match;
    DateTime dayOfEvent = DateTime(sharedEvent.event.startsAt.year, sharedEvent.event.startsAt.month, sharedEvent.event.startsAt.day, 0,0);
    if(_events.containsKey(dayOfEvent)){
      for(Event event in _events[dayOfEvent]!){
        if(event.startsAt.isBefore(sharedEvent.event.endsAt) &&
            event.endsAt.isAfter(sharedEvent.event.startsAt)){
          match = model.Match(friendEvent: sharedEvent, userEvent: event);
          break;
        }
      }
    }
    return match;
  }
}