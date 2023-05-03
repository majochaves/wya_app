import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String eventId;
  final String uid;
  final String description;
  final String locationId;
  final datePublished;
  final startsAt;
  final endsAt;
  final bool sharedWithAll;
  final groups;
  final participants;

  const Event({
    required this.description,
    required this.uid,
    required this.eventId,
    required this.datePublished,
    required this.startsAt,
    required this.endsAt,
    required this.participants,
    required this.locationId,
    required this.sharedWithAll,
    required this.groups,
  });

  Map<String, dynamic> toJson() => {
    "description": description,
    "uid": uid,
    "eventId": eventId,
    "datePublished": datePublished,
    "startsAt" : startsAt,
    "endsAt" : endsAt,
    "sharedWithAll": sharedWithAll,
    "participants": participants,
    "groups" : groups,
    "locationId" : locationId,

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
      participants: snapshot['participants'],
      locationId : snapshot['locationId'],
      groups: snapshot['groups'],
    );
  }
}