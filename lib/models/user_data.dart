import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String name;
  final List events;
  final List groups;
  final bool allowAdd;
  final int maxMatchDistance;
  final List notifications;
  final List chats;
  final List friends;
  final List requests;

  UserData({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.uid,
    required this.username,
    required this.events,
    required this.groups,
    required this.allowAdd,
    required this.maxMatchDistance,
    required this.notifications,
    required this.chats,
    required this.friends,
    required this.requests
  });

  Map<String, dynamic> toJson() => {
    "name" : name,
    "username": username,
    "uid": uid,
    "email": email,
    "photoUrl": photoUrl,
    "events": events,
    "groups": groups,
    "friends": friends,
    "requests": requests,
    "allowAdd" : allowAdd,
    "maxMatchDistance" : maxMatchDistance,
    "notifications" : notifications,
    "chats" : chats,
  };

  static UserData fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserData(
      name: snapshot['name'],
      username: snapshot['username'],
      uid: snapshot['uid'],
      email: snapshot['email'],
      photoUrl: snapshot['photoUrl'],
      events: snapshot['events'],
      groups: snapshot['groups'],
      allowAdd: snapshot['allowAdd'],
      maxMatchDistance: snapshot['maxMatchDistance'],
      notifications: snapshot['notifications'],
      chats: snapshot['chats'],
      friends: snapshot['friends'],
      requests: snapshot['requests'],
    );
  }
}