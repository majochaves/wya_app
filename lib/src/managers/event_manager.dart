import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:wya_final/src/models/event.dart';

class EventManager {
  EventManager();

  Future<Event> getEventById(String eventId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('events')
        .doc(eventId)
        .get();
    return Event.fromSnap(doc);
  }

  Future<void> addEvent(Event event) async {
    await FirebaseFirestore.instance.collection('events')
        .doc(event.eventId)
        .set(event.toJson());
  }

  Future<void> updateEvent(Event event) async {
    await FirebaseFirestore.instance.collection('events')
        .doc(event.eventId)
        .update(event.toJson());
  }

  Future<void> deleteEvent(String eventId) async {
    await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
  }

  Future<void> requestToJoinEvent(String eventId, String uid) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update({
      'requests': FieldValue.arrayUnion([uid])
    });
  }

  Future<void> acceptEventRequest(String eventId, String requesterUID) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update({
      'requests': FieldValue.arrayRemove([requesterUID]),
      'participants': FieldValue.arrayUnion([requesterUID])
    });
  }

  Future<void> joinEvent(String eventId, String uid) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update({
      'requests': FieldValue.arrayRemove([uid]),
      'participants': FieldValue.arrayUnion([uid])
    });
  }

  Future<void> removeParticipant(String eventId, String uid) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update({
      'participants': FieldValue.arrayRemove([uid])
    });
  }

  Future<void> removeOldFriends(String eventId, List oldFriends) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update({
      'sharedWith': FieldValue.arrayRemove(oldFriends),
    });
  }

  Future<void> updateSharedWith(String eventId, List sharedWith) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update({
      'sharedWith': sharedWith,
    });
  }

  Future<void> removeFriendFromUserEvents(String userId, String friendId) async {
    Query doc = FirebaseFirestore.instance
        .collection('events')
        .where('uid', isEqualTo: userId)
        .where('sharedWith', arrayContains: friendId);

    doc.get().then((value) => value.docs.forEach((element) {
      Event event = Event.fromSnap(element);
      removeOldFriends(event.eventId, [friendId]);
    }));
  }
}
