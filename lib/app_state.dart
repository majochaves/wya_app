import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:wya_final/shared_event.dart';
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
  set selectedDay(DateTime selectedDay){
    _selectedDay = selectedDay;
    _endDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 23, 59);
    notifyListeners();
  }

  StreamSubscription<DocumentSnapshot>? _userDataSubscription;
  UserData _userData = UserData.emptyUserData();
  UserData get userData => _userData;
  set userData(UserData userData){
    _userData = userData;
  }

  StreamSubscription<QuerySnapshot>? _friendSubscription;
  List<UserData> _friends = [];
  List<UserData> get friends => _friends;
  Map<String, UserData> _friendMap = <String, UserData>{};

  StreamSubscription<QuerySnapshot>? _requestSubscription;
  List<UserData> _requests = [];
  List<UserData> get requests => _requests;

  StreamSubscription<QuerySnapshot>? _groupSubscription;
  Map<Group, List<UserData>> _groups = {};
  Map<Group, List<UserData>> get groups => _groups;

  StreamSubscription<QuerySnapshot>? _eventSubscription;
  Map<DateTime, List<Event>> _events = {};
  Map<DateTime, List<Event>> get events => _events;
  List<Event> get selectedEvents => events[_selectedDay] ?? [];

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
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) async {
          if(snapshot.data() != null){
            userData = UserData.fromSnap(snapshot);
          }else{
            print('creating userData');
            String randomUsername = '';
            bool uniqueUsername = false;
            while(!uniqueUsername){
              randomUsername = UsernameGen.generateWith(
                  data: UsernameGenData(
                    names: ['new names'],
                    adjectives: ['new adjectives'],
                  ),
                  seperator: '_'
              );
              uniqueUsername = await usernameIsUnique(randomUsername);
            }

            UserData data = UserData(
                email: user.email ?? '',
                name: user.displayName ?? '',
                friends: [],
                requests: [],
                events: [],
                groups: [],
                photoUrl: user.photoURL ?? '',
                uid: user.uid,
                username: randomUsername
            );
            FirebaseFirestore.instance
                .collection('username')
                .doc(randomUsername)
                .set({"username": randomUsername});
            FirebaseFirestore.instance
                .collection('userData')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .set(data.toJson());
          }
          notifyListeners();
        });

        if(userData.requests.isNotEmpty) {
          _requestSubscription =
              FirebaseFirestore.instance
                  .collection('userData')
                  .where('uid', whereIn: _userData.requests)
                  .snapshots()
                  .listen((snapshot) {
                for (final document in snapshot.docs) {
                  UserData requestingUser = UserData.fromSnap(document);
                  _requests.add(requestingUser);
                }
                notifyListeners();
              });
        }

        if(userData.events.isNotEmpty){
          _eventSubscription = FirebaseFirestore.instance
              .collection('events')
              .where('uid', isEqualTo: userData.uid)
              .snapshots()
              .listen((snapshot) {
                for(final document in snapshot.docs){
                  Event event = Event.fromSnap(document);
                  DateTime startsAt = event.startsAt as DateTime;
                  DateTime dayOfEvent = DateTime(startsAt.year, startsAt.month, startsAt.day, 0,0);

                  if(!events.containsKey(dayOfEvent)){
                    events.putIfAbsent(dayOfEvent, () => [event]);
                  }else{
                    events[dayOfEvent]!.add(event);
                  }
                }
          });
        }

        if(userData.friends.isNotEmpty){
        _friendSubscription = FirebaseFirestore.instance
            .collection('userData')
            .where('uid', whereIn: _userData.friends)
            .snapshots()
            .listen((snapshot){
          for(final document in snapshot.docs){
            UserData friend = UserData.fromSnap(document);
            _friendMap.putIfAbsent(friend.uid, () => friend);
            _friends.add(friend);
          }
          notifyListeners();
        });

        if(userData.groups.isNotEmpty){
          _groupSubscription = FirebaseFirestore.instance
              .collection('groups')
              .where('groupId', whereIn: _userData.groups)
              .snapshots()
              .listen((snapshot){
            for(final document in snapshot.docs){
              Group group = Group.fromSnap(document);
              List<UserData> members = friends.where((element) => group.members.contains(element.uid)).toList();
              groups.putIfAbsent(group, () => members);
            }
          });
        }

        _sharedEventSubscription = FirebaseFirestore.instance
            .collection('events')
            .where('sharedWith', arrayContains: user.uid)
            .where('startsAt', isGreaterThanOrEqualTo: Timestamp.fromDate(_selectedDay))
            .where('endsAt', isLessThanOrEqualTo: Timestamp.fromDate(_endDay))
            .snapshots()
            .listen((snapshot) {
          _sharedEvents = [];
          _matches = [];
          for (final document in snapshot.docs) {
            _sharedEvents.add(
                SharedEvent(Event.fromSnap(document), _friendMap[document.data()['uid']]!)
            );
          }
          notifyListeners();
        });
      }
      } else {
        _loggedIn = false;
        _userDataSubscription?.cancel();
        _friendSubscription?.cancel();
        _sharedEventSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  void requestFriend(String uid) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    Future<DocumentSnapshot> snap = FirebaseFirestore.instance.collection('userData').doc(uid).get();
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

  void deleteRequest(String uid) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    Future<DocumentSnapshot> snap = FirebaseFirestore.instance.collection('userData').doc(uid).get();
    List requests = (snap as dynamic)['requests'];

    if(!requests.contains(uid)) {
      FirebaseFirestore.instance
          .collection('userData')
          .doc(uid)
          .update({
        'requests': FieldValue.arrayRemove([userData.uid])
      });
    }
  }

  void addFriend(String uid) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    Future<DocumentSnapshot> snap = FirebaseFirestore.instance.collection('userData').doc(uid).get();
    List friends = (snap as dynamic)['friends'];

    if(!friends.contains(uid)) {
      FirebaseFirestore.instance
          .collection('userData')
          .doc(uid)
          .update({
        'friends': FieldValue.arrayUnion([userData.uid])
      });

      FirebaseFirestore.instance
          .collection('userData')
          .doc(userData.uid)
          .update({
        'friends': FieldValue.arrayUnion([uid])
      });

      deleteRequest(uid);
    }
  }

  void removeFriend(String uid) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    Future<DocumentSnapshot> snap = FirebaseFirestore.instance.collection('userData').doc(uid).get();
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

      deleteRequest(uid);
    }
  }
  void addGroup(Group group) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    FirebaseFirestore.instance.collection('groups').doc(group.groupId).set(group.toJson());

    FirebaseFirestore.instance
        .collection('userData')
        .doc(userData.uid)
        .update({
      'groups': FieldValue.arrayUnion([group.groupId])
    });

  }

  void updateGroup(Group group) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    FirebaseFirestore.instance.collection('groups').doc(group.groupId).update(group.toJson());
  }

  void deleteGroup(String groupId) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    FirebaseFirestore.instance.collection('groups').doc(groupId).delete();

    FirebaseFirestore.instance
        .collection('userData')
        .doc(userData.uid)
        .update({
    'groups': FieldValue.arrayRemove([groupId])
    });

  }

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

  Future<bool> usernameIsUnique(String username) async{
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('usernames')
        .doc(username).get();

    return !doc.exists;
  }
}