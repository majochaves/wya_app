import 'package:cloud_firestore/cloud_firestore.dart';


class Notification{
  final String notificationId;
  final int type;
  final DateTime created;
  final String uid;
  final bool isRead;
  final String userId;
  final String eventId;

  const Notification({required this.userId, required this.eventId, required this.notificationId, required this.type, required this.created, required this.uid, required this.isRead});

  Map<String, dynamic> toJson() => {
    "notificationId" : notificationId,
    "type" : type,
    "created" : created,
    "uid" : uid,
    "isRead" : isRead,
    "userId" : userId,
    "eventId" : eventId
  };

  static Notification fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Notification(
      notificationId: snapshot['notificationId'],
      type: snapshot['type'],
      uid: snapshot['uid'],
      created: DateTime.parse(snapshot['created'].toDate().toString()),
      isRead: snapshot['isRead'],
      userId: snapshot['userId'],
      eventId : snapshot['eventId']
    );
  }
}