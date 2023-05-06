import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:wya_final/location.dart';
import 'package:wya_final/shared_event.dart';
import 'package:wya_final/src/location_provider.dart';
import 'package:wya_final/user_data.dart';
import 'package:username_gen/username_gen.dart';

import 'event.dart';
import 'group.dart';
import 'match.dart' as model;
import 'firebase_options.dart';                    // new

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

  StreamSubscription<QuerySnapshot>? _sharedEventSubscription;
  List<SharedEvent> _sharedEvents = [];
  List<SharedEvent> get sharedEvents => _sharedEvents;
  List<model.Match> _matches = [];
  List<model.Match> get matches => _matches;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
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
                  .snapshots()
                  .listen((snapshot) {
                _events = {};
                for(final document in snapshot.docs){
                  Event event = Event.fromSnap(document);
                  DateTime startsAt = event.startsAt as DateTime;
                  DateTime dayOfEvent = DateTime(startsAt.year, startsAt.month, startsAt.day, 0,0);

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
              notifyListeners();
            }else{
              print("friends is not empty");
              _friendSubscription = FirebaseFirestore.instance
                  .collection('userData')
                  .where('uid', whereIn: userData.friends)
                  .snapshots()
                  .listen((snapshot){
                _friends = [];
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

              ///_sharedEventSubscription = FirebaseFirestore.instance
                  ///.collection('events')
          ///.where('sharedWith', arrayContains: user.uid)
          ///.where('startsAt', isGreaterThanOrEqualTo: Timestamp.fromDate(_selectedDay))
          ///.where('endsAt', isLessThanOrEqualTo: Timestamp.fromDate(_endDay))
          ///.snapshots()
              ///.listen((snapshot) {
              ///_sharedEvents = [];
              ///_matches = [];
              ///for (final document in snapshot.docs) {
              ///_sharedEvents.add(
          ///SharedEvent(Event.fromSnap(document), _friendMap[document.data()['uid']]!)
              ///);
              ///}
              ///notifyListeners();
              ///});
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
                photoUrl: 'https://picsum.photos/250?image=9',
                uid: user.uid,
                username: randomUsername
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
      }
      notifyListeners();
    });
  }

  Event getEventById(String eventId){
    List<Event> matchingEvents = selectedEvents.where((element) => element.eventId == eventId).toList();
    return matchingEvents.first;
  }
  Future<Location> getLocationById(String locationId) async{
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
        address: location.adrAddress,
        url: location.url,
        latitude: location.geometry!.location.lat,
        longitude: location.geometry!.location.lng,
        name: location.name);

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
  Future<void> updateEvent(Event event) async{
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
  Future<bool> usernameIsUnique(String username) async{
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('usernames')
        .doc(username).get();

    return !doc.exists;
  }
}