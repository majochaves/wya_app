import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Event>> getEvents(String uid){
    return _db
          .collection('events')
          .where('uid', isEqualTo: uid)
          .orderBy('startsAt')
          .snapshots().map((snapshot) =>
          snapshot.docs
              .map((document) => Event.fromSnap(document))
              .toList());
  }

  Stream<List<Event>> getSharedEvents(String uid){
      return _db
          .collection('events')
          .orderBy('startsAt')
          .where('sharedWith', arrayContains: uid)
          .snapshots().map((snapshot) =>
          snapshot.docs
              .map((document) => Event.fromSnap(document))
              .toList());
  }


  Future<Event> getEventById(String eventId) async {
    DocumentSnapshot doc = await _db.collection('events')
        .doc(eventId)
        .get();
    return Event.fromSnap(doc);
  }

  Future<void> saveEvent(Event event) async {
    await _db.collection('events')
        .doc(event.eventId)
        .set(event.toJson());
  }

  Future<void> updateEvent(Event event) async {
    await _db.collection('events')
        .doc(event.eventId)
        .update(event.toJson());
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  Future<void> requestToJoinEvent(String eventId, String uid) async {
    await _db
        .collection('events')
        .doc(eventId)
        .update({
      'requests': FieldValue.arrayUnion([uid])
    });
  }

  Future<void> acceptEventRequest(String eventId, String requesterUID) async {
    await _db
        .collection('events')
        .doc(eventId)
        .update({
      'requests': FieldValue.arrayRemove([requesterUID]),
      'participants': FieldValue.arrayUnion([requesterUID])
    });
  }

  Future<void> joinEvent(String eventId, String uid) async {
    await _db
        .collection('events')
        .doc(eventId)
        .update({
      'requests': FieldValue.arrayRemove([uid]),
      'participants': FieldValue.arrayUnion([uid])
    });
  }

  Future<void> removeParticipant(String eventId, String uid) async {
    await _db
        .collection('events')
        .doc(eventId)
        .update({
      'participants': FieldValue.arrayRemove([uid])
    });
  }

  Future<void> addParticipant(String eventId, String uid) async {
    await _db
        .collection('events')
        .doc(eventId)
        .update({
      'participants': FieldValue.arrayUnion([uid])
    });
  }

  Future<void> updateSharedWith(String eventId, List sharedWith) async {
    await _db
        .collection('events')
        .doc(eventId)
        .update({
      'sharedWith': sharedWith,
    });
  }

  Future<void> removeOldFriends(String eventId, List oldFriends) async {
    await _db
        .collection('events')
        .doc(eventId)
        .update({
      'sharedWith': FieldValue.arrayRemove(oldFriends),
    });
  }

  Future<void> removeFriendFromUserEvents(String userId, String friendId) async {
    Query doc = _db
        .collection('events')
        .where('uid', isEqualTo: userId)
        .where('sharedWith', arrayContains: friendId);

    doc.get().then((value) => value.docs.forEach((element) {
      Event event = Event.fromSnap(element);
      removeOldFriends(event.eventId, [friendId]);
    }));
  }

}