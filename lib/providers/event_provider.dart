import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:wya_final/providers/user_provider.dart';

import '../models/event.dart';
import '../models/group.dart';
import '../models/location.dart';
import '../models/shared_event.dart';
import '../models/user_data.dart';
import '../models/match.dart' as model;
import '../models/notification.dart' as model;

import '../services/event_service.dart';
import '../services/group_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';


class EventProvider with ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;
  static const Uuid uuid = Uuid();

  ///Constructor
  EventProvider(){
    init();
  }

  ///ChangeNotifierProxy Update Method: Updates when UserProvider has been updated
  void update(UserProvider provider){
    friendInfo = provider.friendInfo;
    maxMatchDistance = provider.maxMatchDistance;
    notifyListeners();
  }

  ///Services
  EventService eventService = EventService();
  EventLocationService eventLocationService = EventLocationService();
  GroupService groupService = GroupService();
  UserService userService = UserService();
  NotificationService notificationService = NotificationService();

  ///Shared data from User provider
  List<UserData> friendInfo = [];
  int? maxMatchDistance = 0;

  ///Provider values
  DateTime selectedDay = DateTime.now();

  Map<DateTime, List<Event>> eventMap = {};
  List<Event> events = [];
  List<Event> eventsForDay(DateTime day){
    DateTime dayOfEvent = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 0,0);
    return eventMap[dayOfEvent] ?? [];
  }

  Map<DateTime, List<SharedEvent>> sharedEventsMap = {};
  List<SharedEvent> sharedEvents = [];
  List<SharedEvent> sharedEventsForDay(DateTime day){
    DateTime dayOfEvent = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 0,0);
    return sharedEventsMap[dayOfEvent] ?? [];
  }

  Map<DateTime, List<SharedEvent>> joinedEvents = {};
  List<SharedEvent> joinedEventsForDay(DateTime day){
    DateTime dayOfEvent = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 0,0);
    return joinedEvents[dayOfEvent] ?? [];
  }

  Map<DateTime, List<model.Match>> matches = {};
  List<model.Match> matchesForDay(DateTime day){
    DateTime dayOfEvent = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 0,0);
    return matches[dayOfEvent] ?? [];
  }

  Event? selectedEvent;
  void setSelectedEvent(Event event){
    selectedEvent = event;
    if(selectedEvent != null){
      loadEvent(selectedEvent!);
    }else{
      newEvent();
    }
    notifyListeners();
  }

  SharedEvent? selectedSharedEvent;
  void setSelectedSharedEvent(SharedEvent event){
    selectedSharedEvent = event;
    if(selectedSharedEvent != null){
      loadEvent(selectedSharedEvent!.event);
    }else{
      newEvent();
    }
    notifyListeners();
  }

  List<Group> groupInfo = [];

  void init(){
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        groupService.getGroups(user.uid).listen((groupList) {
          groupInfo = groupList;
          notifyListeners();
        });
        eventService.getEvents(user.uid).listen((eventsList) {
          events = eventsList;
           for(Event event in eventsList){
             DateTime startsAt = event.startsAt as DateTime;
             DateTime dayOfEvent = DateTime(startsAt.year, startsAt.month, startsAt.day, 0,0);
             ///Found current selected event
             if(selectedEvent != null && selectedEvent!.eventId == event.eventId){
               selectedEvent = event;
               loadEvent(selectedEvent!);
             }
             ///If map does not contain key for day of event, we add a new entry with an empty list
             if(!eventMap.containsKey(dayOfEvent)){
               eventMap.putIfAbsent(dayOfEvent, () => []);
             }
             ///If key value list already contains the event, we replace it with the new value
             if(eventMap[dayOfEvent]!.any((element) => element.eventId == event.eventId)){
               eventMap[dayOfEvent]![eventMap[dayOfEvent]!.indexWhere((element) => element.eventId == event.eventId)] = event;
             }else{///If key value list does not contain event, we add it
               eventMap[dayOfEvent]!.add(event);
             }
           }
           notifyListeners();
         });
        eventService.getSharedEvents(user.uid).listen((sharedEventsList) async {
           for(Event event in sharedEventsList){
             DateTime startsAt = event.startsAt as DateTime;
             DateTime dayOfEvent = DateTime(startsAt.year, startsAt.month, startsAt.day, 0,0);
             UserData friend = friendInfo[friendInfo.indexWhere((element) => element.uid == event.uid)];

             if(sharedEvents.any((element) => element.event.eventId == event.eventId)){
               sharedEvents[sharedEvents.indexWhere((element) => element.event.eventId == event.eventId)] = SharedEvent(event, friend);
             }else{
               sharedEvents.add(SharedEvent(event, friend));
             }

             if(selectedSharedEvent != null && selectedSharedEvent!.event.eventId == event.eventId){
               selectedSharedEvent = SharedEvent(event, friend);
               loadEvent(selectedSharedEvent!.event);
             }

             if(event.participants.contains(user.uid)){
               if(!joinedEvents.containsKey(dayOfEvent)){
                 joinedEvents.putIfAbsent(dayOfEvent, () => []);
               }
               if(joinedEvents[dayOfEvent]!.any((element) => element.event.eventId == event.eventId)){
                 joinedEvents[dayOfEvent]![joinedEvents[dayOfEvent]!.indexWhere((element) => element.event.eventId == event.eventId)] = SharedEvent(event, friend);
               }else{
                 joinedEvents[dayOfEvent]!.add(SharedEvent(event, friend));
               }
             }

             if(!sharedEventsMap.containsKey(dayOfEvent)){
               sharedEventsMap.putIfAbsent(dayOfEvent, () => []);
             }
             if(sharedEventsMap[dayOfEvent]!.any((element) => element.event.eventId == event.eventId)){
               sharedEventsMap[dayOfEvent]![sharedEventsMap[dayOfEvent]!.indexWhere((element) => element.event.eventId == event.eventId)] = SharedEvent(event, friend);
             }else{
               sharedEventsMap[dayOfEvent]!.add(SharedEvent(event, friend));
             }

             model.Match? match = await isThereMatch(SharedEvent(event, friend));

             if(match != null){
               if(!matches.containsKey(dayOfEvent)){
                 matches.putIfAbsent(dayOfEvent, () => []);
               }
               if(matches[dayOfEvent]!.any((element) => element.friendEvent.event.eventId == event.eventId)) {
                 matches[dayOfEvent]![matches[dayOfEvent]!.indexWhere((element) => element.friendEvent.event.eventId == event.eventId)] = match;
               }else{
                 matches[dayOfEvent]!.add(match);
               }
             }
           }
           notifyListeners();
         });
      }
    });
  }

  ///Auxiliary method to check if there is a match for a given shared event
  Future<model.Match?> isThereMatch(SharedEvent sharedEvent) async {
    model.Match? match;
    DateTime dayOfEvent = DateTime(sharedEvent.event.startsAt.year, sharedEvent.event.startsAt.month, sharedEvent.event.startsAt.day, 0,0);
    if(eventMap.containsKey(dayOfEvent)){
      for(Event event in eventMap[dayOfEvent]!){
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
          if(distance <= maxMatchDistance!){
            match = model.Match(friendEvent: sharedEvent, userEvent: event);
            break;
          }
        }
      }
    }
    return match;
  }

  ///Event model values
  String? _eventId;
  String _uid = '';
  String _description = '';
  Location? _location;
  int _category = 0;
  DateTime? _datePublished;
  DateTime _startsAt = DateTime.now();
  DateTime _endsAt = DateTime.now();
  bool _sharedWithAll = true;
  bool _isOpen = false;
  List<Group> _groups = [];
  List<UserData> _sharedWith = [];
  List<UserData> _participants = [];
  List<UserData> _requests = [];

  ///Event model getters and setters
  String? get eventId => _eventId;
  set eventId(String? value) {
    _eventId = value;
    notifyListeners();
  }
  String get uid => _uid;
  set uid(String value) {
    _uid = value;
    notifyListeners();
  }
  String get description => _description;
  set description(String value) {
    _description = value;
    notifyListeners();
  }
  Location? get location => _location;
  int get category => _category;
  set category(int value) {
    _category = value;
    notifyListeners();
  }
  DateTime? get datePublished => _datePublished;
  set datePublished(DateTime? value) {
    _datePublished = value;
    notifyListeners();
  }
  DateTime get startsAt => _startsAt;
  set startsAt(DateTime value) {
    _startsAt = value;
    notifyListeners();
  }
  DateTime get endsAt => _endsAt;
  set endsAt(DateTime value) {
    _endsAt = value;
    notifyListeners();
  }
  bool get sharedWithAll => _sharedWithAll;
  set sharedWithAll(bool value) {
    _sharedWithAll = value;
    notifyListeners();
  }
  bool get isOpen => _isOpen;
  set isOpen(bool value) {
    _isOpen = value;
    notifyListeners();
  }
  List<Group> get groups => _groups;
  set groups(List<Group> value) {
    _groups = value;
    notifyListeners();
  }
  List<UserData> get sharedWith => _sharedWith;
  set sharedWith(List<UserData> value) {
    _sharedWith = value;
    notifyListeners();
  }
  List<UserData> get participants => _participants;
  set participants(List<UserData> value) {
    _participants = value;
    notifyListeners();
  }

  List<UserData> get requests => _requests;
  set requests(List<UserData> value) {
    _requests = value;
    notifyListeners();
  }

  void setLocation(String formattedAddress, String url, double latitude, double longitude) {
    Location location = Location(locationId: const Uuid().v1(), uid: user!.uid, formattedAddress: formattedAddress, url: url, latitude: latitude, longitude: longitude);
    _location = location;
    notifyListeners();
  }
  void addGroup(Group group){
    _groups.add(group);
    notifyListeners();
  }
  void removeGroup(Group group){
    _groups.remove(group);
    notifyListeners();
  }
  void addUserToSharedWith(UserData user){
    _sharedWith.add(user);
    notifyListeners();
  }
  void removeUserFromSharedWith(UserData user){
    _sharedWith.remove(user);
    notifyListeners();
  }
  void removeUsersFromSharedWith(List<UserData> users){
    _sharedWith.removeWhere((element) => users.contains(element));
    notifyListeners();
  }
  void addParticipant(UserData user){
    _participants.add(user);
    notifyListeners();
  }

  void removeParticipant(UserData user){
    _participants.add(user);
    notifyListeners();
  }

  void addRequest(UserData user){
    _requests.add(user);
    notifyListeners();
  }
  void removeRequest(UserData user){
    _requests.remove(user);
    notifyListeners();
  }
  Future<void> requestToJoinEvent(String eventId) async{
    Event event = getSharedEventById(eventId);
    await eventService.requestToJoinEvent(eventId, user!.uid);

    String notificationId = uuid.v1();
    model.Notification notification
      = model.Notification(
          notificationId:  notificationId,
          type: 2,
          created: DateTime.now(),
          uid: event.uid,
          isRead: false,
          userId: user!.uid,
          eventId: eventId
      );

    await notificationService.saveNotification(notification);

    await userService.addNotification(event.uid, notificationId);
  }

  Future<void> joinEvent(String eventId) async{
    Event event = getSharedEventById(eventId);
    await eventService.joinEvent(eventId, user!.uid);

    String notificationId = uuid.v1();
    model.Notification notification
      = model.Notification(
          notificationId: notificationId,
          type: 4,
          created: DateTime.now(),
          uid: event.uid,
          isRead: false,
          userId: user!.uid,
          eventId: eventId
      );

    await notificationService.saveNotification(notification);
    await userService.addNotification(event.uid, notificationId);
  }

  Future<void> acceptEventRequest(String eventId, UserData requester) async{
    Event event = getEventById(eventId);
    if(event.requests.contains(requester)){
      removeRequest(requester);
      addParticipant(requester);
      await eventService.acceptEventRequest(eventId, requester.uid);

      ///Create notification letting requesting user know that their
      ///request has been accepted
      String notificationId = uuid.v1();
      model.Notification notification
        = model.Notification(
            notificationId: notificationId,
            type: 3,
            created: DateTime.now(),
            uid: requester.uid,
            isRead: false,
            userId: user!.uid,
            eventId: eventId
        );

      await notificationService.saveNotification(notification);
      await userService.addNotification(requester.uid, notificationId);
    }
  }

  Future<void> removeParticipantFromEvent(String eventId, UserData user) async{
    Event event = getEventById(eventId);
    if(event.participants.contains(user)){
      removeParticipant(user);
      await eventService.removeParticipant(eventId, user.uid);
    }
  }
  ///Aux methods
  Event getSharedEventById(String eventId){
    return sharedEvents[sharedEvents.indexWhere((element) => element.event.eventId == eventId)].event;
  }

  Event getEventById(String eventId){
    return events[events.indexWhere((element) => element.eventId == eventId)];
  }
  List<Group> getGroupsContainedIn(List list){
    List<Group> groupsContainedIn = List.from(groupInfo);
    groupsContainedIn.removeWhere((element) => !list.contains(element.groupId));
    return groupsContainedIn;
  }

  List<UserData> getFriendsContainedIn(List list){
    List<UserData> friendsContainedIn = List.from(friendInfo);
    friendsContainedIn.removeWhere((element) => !list.contains(element.uid));
    return friendsContainedIn;
  }

  ///Load event values
  void loadEvent(Event event) async{
    _eventId = event.eventId;
    _uid = event.uid;
    _description = event.description;
    _location = await eventLocationService.getLocationById(event.locationId);
    _category = 0;
    _datePublished;
    _startsAt = DateTime.now();
    _endsAt = DateTime.now();
    _sharedWithAll = true;
    _isOpen = false;
    _groups = getGroupsContainedIn(event.groups);
    _sharedWith = getFriendsContainedIn(event.sharedWith);
    _participants = getFriendsContainedIn(event.participants);
    _requests = getFriendsContainedIn(event.requests);
    notifyListeners();
  }
  ///Set new event values
  void newEvent(){
    _eventId = null;
    _uid = user!.uid;
    _description = '';
    _location;
    _category = 0;
    _datePublished;
    _startsAt = DateTime.now();
    _endsAt = DateTime.now();
    _sharedWithAll = true;
    _isOpen = false;
    _groups = [];
    _sharedWith = [];
    _participants = [];
    _requests = [];
    notifyListeners();
  }

  ///Save event to database
  saveEvent(){
    eventLocationService.saveLocation(location!);
    if(eventId == null){
      eventId == uuid.v1();
      Event newEvent = Event(
          description: description,
          uid: uid,
          eventId: eventId!,
          datePublished: datePublished,
          startsAt: startsAt,
          endsAt: endsAt,
          participants: participants.map((e) => e.uid).toList(),
          locationId: location!.locationId,
          sharedWithAll: sharedWithAll,
          isOpen: isOpen,
          groups: groups.map((g) => g.groupId).toList(),
          category: category,
          sharedWith: sharedWith.map((e) => e.uid).toList(),
          requests: requests.map((e) => e.uid).toList());
      eventService.saveEvent(newEvent);
      userService.addEvent(uid, eventId!);
    }else{
      Event updatedEvent = Event(
          description: description,
          uid: uid,
          eventId: eventId!,
          datePublished: datePublished,
          startsAt: startsAt,
          endsAt: endsAt,
          participants: participants.map((e) => e.uid).toList(),
          locationId: location!.locationId,
          sharedWithAll: sharedWithAll,
          isOpen: isOpen,
          groups: groups.map((g) => g.groupId).toList(),
          category: category,
          sharedWith: sharedWith.map((e) => e.uid).toList(),
          requests: requests.map((e) => e.uid).toList());
      eventService.updateEvent(updatedEvent);
    }
  }

  ///Delete event from database
  void deleteEvent(String eventId) async{
    await eventService.deleteEvent(eventId);
    await userService.deleteEvent(user!.uid, eventId);
  }
}