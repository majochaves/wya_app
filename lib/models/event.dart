import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Event {
  final String eventId;
  final String uid;
  final String description;
  final String locationId;
  final int category;
  final datePublished;
  final startsAt;
  final endsAt;
  final bool sharedWithAll;
  final bool isOpen;
  final groups;
  final sharedWith;
  final participants;
  final requests;

  const Event(  {
    required this.description,
    required this.uid,
    required this.eventId,
    required this.datePublished,
    required this.startsAt,
    required this.endsAt,
    required this.participants,
    required this.locationId,
    required this.sharedWithAll,
    required this.isOpen,
    required this.groups,
    required this.category,
    required this.sharedWith,
    required this.requests,
  });

  Map<String, dynamic> toJson() => {
    "description": description,
    "uid": uid,
    "eventId": eventId,
    "datePublished": datePublished,
    "startsAt" : startsAt,
    "endsAt" : endsAt,
    "sharedWithAll": sharedWithAll,
    "isOpen" :isOpen,
    "participants": participants,
    "groups" : groups,
    "locationId" : locationId,
    "category" : category,
    "sharedWith" : sharedWith,
    "requests" : requests,
  };

  static Event fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Event(
      description: snapshot['description'],
      uid: snapshot['uid'],
      eventId: snapshot['eventId'],
      datePublished: DateTime.parse(snapshot['datePublished'].toDate().toString()),
      startsAt: DateTime.parse(snapshot['startsAt'].toDate().toString()),
      endsAt: DateTime.parse(snapshot['endsAt'].toDate().toString()),
      sharedWithAll: snapshot['sharedWithAll'],
      isOpen: snapshot['isOpen'],
      participants: snapshot['participants'],
      locationId : snapshot['locationId'],
      groups: snapshot['groups'],
      category: snapshot['category'],
      sharedWith: snapshot['sharedWith'],
      requests: snapshot['requests'],
    );
  }
  static Event emptyEvent(String uid, DateTime startsAt, DateTime endsAt){
    return Event(
        description: '',
        uid: uid,
        eventId: const Uuid().v1(),
        datePublished: null,
        startsAt: startsAt,
        endsAt: endsAt,
        participants: [],
        locationId: '',
        sharedWithAll: true,
        isOpen: false,
        groups: [],
        category: 1,
        requests: [],
        sharedWith: []);
  }

}

