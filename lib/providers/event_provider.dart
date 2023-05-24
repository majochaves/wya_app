import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_calendar/table_calendar.dart';
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
  DateTime _selectedDay = DateTime.now();
  DateTime get selectedDay => _selectedDay;
  DateTime _endDay = DateTime.now();
  DateTime get endDay => _endDay;
  set selectedDay(DateTime selectedDay){
    _selectedDay = selectedDay;
    _endDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 23, 59);
    notifyListeners();
  }

  Map<DateTime, List<Event>> eventMap = {};
  List<Event> events = [];
  List<Event> eventsForDay(DateTime day){
    DateTime dayOfEvent = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 0,0);
    return eventMap[dayOfEvent] ?? [];
  }

  Map<DateTime, List<SharedEvent>> sharedEventsMap = {};
  List<SharedEvent> sharedEvents = [];
  List<SharedEvent> sharedEventsForDay(DateTime day){
    DateTime dayOfEvent = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 0,0);
    return sharedEventsMap[dayOfEvent] ?? [];
  }

  Map<DateTime, List<SharedEvent>> joinedEvents = {};
  List<SharedEvent> joinedEventsForDay(DateTime day){
    DateTime dayOfEvent = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 0,0);
    return joinedEvents[dayOfEvent] ?? [];
  }

  Map<DateTime, List<model.Match>> matches = {};
  List<model.Match> matchesForDay(DateTime day){
    DateTime dayOfEvent = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 0,0);
    return matches[dayOfEvent] ?? [];
  }

  Event? selectedEvent;
  Future<void> setSelectedEvent(Event event) async{
    selectedEvent = event;
    if(selectedEvent != null){
      getSelectedEventStream = eventService.getEventStream(event.eventId).listen((event) async{
        selectedEvent = event;
        await loadEvent(event);
        notifyListeners();
      });
    }else{
      getSelectedEventStream?.cancel();
      newEvent();
    }
    notifyListeners();
  }

  SharedEvent? selectedSharedEvent;
  Future<void> setSelectedSharedEvent(SharedEvent event) async{
    selectedSharedEvent = event;
    if(selectedSharedEvent != null){
      getSelectedSharedEventStream = eventService.getEventStream(event.event.eventId).listen((event) async{
        selectedSharedEvent = SharedEvent(event, selectedSharedEvent!.user);
        await loadEvent(selectedSharedEvent!.event);
        notifyListeners();
      });
    }else{
      newEvent();
    }
    notifyListeners();
  }

  List<Group> groupInfo = [];

  StreamSubscription? getEventsStream;
  StreamSubscription? getSharedEventsStream;
  StreamSubscription? getSelectedEventStream;
  StreamSubscription? getSelectedSharedEventStream;

  void cancelStreams(){
    getEventsStream?.cancel();
    getSharedEventsStream?.cancel();
    getSelectedEventStream?.cancel();
    getSelectedSharedEventStream?.cancel();
  }

  void clearData(){
    groupInfo.clear();
    events.clear();
    eventMap.clear();
    sharedEvents.clear();
    sharedEventsMap.clear();
    matches.clear();
    joinedEvents.clear();
    friendInfo.clear();
    _groups.clear();
    _sharedWith.clear();
    _participants.clear();
    requests.clear();
    selectedSharedEvent = null;
    selectedEvent = null;
    maxMatchDistance = 0;
    _eventId = null;
    _uid = null;
    _description = null;
    _location = null;
    _category = null;
    _datePublished = null;
    _startsAt = null;
    _endsAt = null;
    _sharedWithAll = null;
    _isOpen = null;
    notifyListeners();
  }

  void init(){
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        groupService.getGroups(user.uid).listen((groupList) {
          groupInfo = groupList;
          notifyListeners();
        });
        getEventsStream = eventService.getEvents(user.uid).listen((eventsList) {
          events = eventsList;
          eventMap = {};
           for(Event event in eventsList){
             DateTime startsAt = event.startsAt as DateTime;
             DateTime dayOfEvent = DateTime(startsAt.year, startsAt.month, startsAt.day, 0,0);
             ///Found current selected event
             /*if(selectedEvent != null && selectedEvent!.eventId == event.eventId){
               selectedEvent = event;
               loadEvent(selectedEvent!);
             }*/
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
        getSharedEventsStream = eventService.getSharedEvents(user.uid).listen((sharedEventsList) async {
          print('received stream: ${sharedEventsList.toString()}');
          sharedEvents = [];
          sharedEventsMap = {};
          joinedEvents = {};
          matches = {};
          notifyListeners();
           for(Event event in sharedEventsList){
             DateTime startsAt = event.startsAt as DateTime;
             DateTime dayOfEvent = DateTime(startsAt.year, startsAt.month, startsAt.day, 0,0);
             UserData friend = await getFriendFromId(event.uid);

             if(sharedEvents.any((element) => element.event.eventId == event.eventId)){
               sharedEvents[sharedEvents.indexWhere((element) => element.event.eventId == event.eventId)] = SharedEvent(event, friend);
             }else{
               sharedEvents.add(SharedEvent(event, friend));
             }

             /*
             if(selectedSharedEvent != null && selectedSharedEvent!.event.eventId == event.eventId){
               selectedSharedEvent = SharedEvent(event, friend);
               loadEvent(selectedSharedEvent!.event);
             }*/

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
      }else{
        cancelStreams();
        clearData();
        print('event provider: reset');
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
          Location? locationEvent = await eventLocationService.getLocationById(event.locationId);
          Location? locationSharedEvent = await eventLocationService.getLocationById(sharedEvent.event.locationId);
          double lat1 = locationEvent!.latitude;
          double lon1 = locationEvent!.longitude;
          double lat2 = locationSharedEvent!.latitude;
          double lon2 = locationSharedEvent!.longitude;
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
  Future<UserData> getFriendFromId(String id) async{
    if(friendInfo.any((element) => element.uid == id)){
      return friendInfo[friendInfo.indexWhere((element) => element.uid == id)];
    }else{
      return await userService.getUserById(id);
    }

  }

  ///Event model values
  String? _eventId;
  String? _uid;
  String? _description;
  Location? _location;
  int? _category;
  DateTime? _datePublished;
  DateTime? _startsAt;
  DateTime? _endsAt;
  bool? _sharedWithAll;
  bool? _isOpen;
  List<Group> _groups = [];
  List<UserData> _sharedWith = [];
  List<UserData> _participants = [];
  List<UserData> _requests = [];
  List _requestIDs = [];
  List _participantIDs = [];

  ///Event model getters and setters
  String? get eventId => _eventId;
  set eventId(String? value) {
    _eventId = value;
    notifyListeners();
  }
  String? get uid => _uid;
  set uid(String? value) {
    _uid = value;
    notifyListeners();
  }
  String? get description => _description;
  set description(String? value) {
    _description = value;
    notifyListeners();
  }
  Location? get location => _location;
  int? get category => _category;
  set category(int? value) {
    _category = value;
    notifyListeners();
  }
  DateTime? get datePublished => _datePublished;
  set datePublished(DateTime? value) {
    _datePublished = value;
    notifyListeners();
  }
  DateTime? get startsAt => _startsAt;
  set startsAt(DateTime? value) {
    _startsAt = value;
    notifyListeners();
  }
  DateTime? get endsAt => _endsAt;
  set endsAt(DateTime? value) {
    _endsAt = value;
    notifyListeners();
  }
  bool? get sharedWithAll => _sharedWithAll;
  set sharedWithAll(bool? value) {
    _sharedWithAll = value;
    if(value != null) {
      if (value) {
        sharedWith = friendInfo;
      } else {
        sharedWith = [];
      }
    }
    notifyListeners();
  }
  bool? get isOpen => _isOpen;
  set isOpen(bool? value) {
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

  List get participantIDs => _participantIDs;
  set participantIDs(List value) {
    _participantIDs = value;
    notifyListeners();
  }

  List get requestIDs => _requestIDs;
  set requestIDs(List value) {
    _requestIDs = value;
    notifyListeners();
  }

  void setLocation(String formattedAddress, String url, double latitude, double longitude) {
    Location location = Location(locationId: const Uuid().v1(), uid: FirebaseAuth.instance.currentUser!.uid, formattedAddress: formattedAddress, url: url, latitude: latitude, longitude: longitude);
    print('new location set: ${location.locationId}');
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
    await eventService.requestToJoinEvent(eventId, FirebaseAuth.instance.currentUser!.uid);

    String notificationId = uuid.v1();
    model.Notification notification
      = model.Notification(
          notificationId:  notificationId,
          type: 2,
          created: DateTime.now(),
          uid: event.uid,
          isRead: false,
          userId: FirebaseAuth.instance.currentUser!.uid,
          eventId: eventId
      );

    notificationService.saveNotification(notification);

    userService.addNotification(event.uid, notificationId);
  }

  Future<void> joinEvent(String eventId) async{
    Event event = getSharedEventById(eventId);
    await eventService.joinEvent(eventId, FirebaseAuth.instance.currentUser!.uid);

    String notificationId = uuid.v1();
    model.Notification notification
      = model.Notification(
          notificationId: notificationId,
          type: 4,
          created: DateTime.now(),
          uid: event.uid,
          isRead: false,
          userId: FirebaseAuth.instance.currentUser!.uid,
          eventId: eventId
      );

    notificationService.saveNotification(notification);
    userService.addNotification(event.uid, notificationId);
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
            userId: FirebaseAuth.instance.currentUser!.uid,
            eventId: eventId
        );

      notificationService.saveNotification(notification);
      userService.addNotification(requester.uid, notificationId);
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

  Future<void> getLocation(Event event) async{
    _location = await eventLocationService.getLocationById(event.locationId);
  }

  ///Load event values
  Future<void> loadEvent(Event event) async{
    _eventId = event.eventId;
    _uid = event.uid;
    _description = event.description;
    _category = event.category;
    _datePublished = event.datePublished;
    _startsAt = event.startsAt;
    _endsAt = event.endsAt;
    _sharedWithAll = event.sharedWithAll;
    _isOpen = event.isOpen;
    _participantIDs = event.participants;
    _requestIDs = event.requests;
    _groups = getGroupsContainedIn(event.groups);
    _sharedWith = getFriendsContainedIn(event.sharedWith);
    _participants = getFriendsContainedIn(event.participants);
    _requests = getFriendsContainedIn(event.requests);
    notifyListeners();
    Location? eventLocation = await eventLocationService.getLocationById(event.locationId);
    _location = eventLocation;
    print('got event location');
    notifyListeners();
  }
  ///Set new event values
  void newEvent(){
    _eventId = null;
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _description = '';
    _location;
    _category = 0;
    _datePublished;
    _startsAt = isSameDay(_selectedDay, DateTime.now()) ? DateTime.now() : DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 0, 0);
    _endsAt = DateTime(_startsAt!.year, _startsAt!.month, _startsAt!.day, 23, 59);
    _sharedWithAll = true;
    _isOpen = false;
    _groups = [];
    _sharedWith = friendInfo;
    _participants = [];
    _requests = [];
    notifyListeners();
  }

  ///Save event to database
  saveEvent(){
    eventLocationService.saveLocation(location!);
    if(eventId == null){
      eventId = uuid.v1();
      Event newEvent = Event(
          description: description!,
          uid: uid!,
          eventId: eventId!,
          datePublished: DateTime.now(),
          startsAt: startsAt,
          endsAt: endsAt,
          participants: participants.map((e) => e.uid).toList(),
          locationId: location!.locationId,
          sharedWithAll: sharedWithAll!,
          isOpen: isOpen!,
          groups: groups.map((g) => g.groupId).toList(),
          category: category!,
          sharedWith: sharedWith.map((e) => e.uid).toList(),
          requests: requests.map((e) => e.uid).toList());
      eventService.saveEvent(newEvent);
      userService.addEvent(uid!, eventId!);
    }else{
      Event updatedEvent = Event(
          description: description!,
          uid: uid!,
          eventId: eventId!,
          datePublished: datePublished,
          startsAt: startsAt,
          endsAt: endsAt,
          participants: participants.map((e) => e.uid).toList(),
          locationId: location!.locationId,
          sharedWithAll: sharedWithAll!,
          isOpen: isOpen!,
          groups: groups.map((g) => g.groupId).toList(),
          category: category!,
          sharedWith: sharedWith.map((e) => e.uid).toList(),
          requests: requests.map((e) => e.uid).toList());
      eventService.updateEvent(updatedEvent);
    }
  }

  ///Delete event from database
  void deleteEvent(String eventId) async{
    await eventService.deleteEvent(eventId);
    await userService.deleteEvent(FirebaseAuth.instance.currentUser!.uid, eventId);
  }

}