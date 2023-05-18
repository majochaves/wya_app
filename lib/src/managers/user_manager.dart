import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_data.dart';

class UserManager{
  UserManager();

  Future<UserData> getUserById(String uid) async{
    DocumentSnapshot userSnap = await FirebaseFirestore.instance.collection('userData').doc(uid).get();
    return UserData.fromSnap(userSnap);
  }

  Future<void> createUserData(UserData userData) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(userData.uid)
        .set(userData.toJson());
  }

  Future<void> changeAllowAdd(bool value, String uid) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'allowAdd': value
    });
  }

  Future<void> changeMaxMatchDistance(double value, String uid) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'maxMatchDistance': value.toInt()
    });
  }

  Future<void> changeProfilePicture(String photoUrl, String uid) async{
    await FirebaseFirestore.instance.collection('userData').doc(uid).update({'photoUrl' : photoUrl});
  }

  Future<void> changeName(String name, String uid) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'name': name
    });
  }
  Future<void> changeUsername(String username, String uid) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'username': username
    });
  }
  Future<void> changeEmail(String email, String uid) {
    return FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'email': email
    });
  }

  Future<bool> emailIsUnique(String email, String uid) async{
    Query doc = FirebaseFirestore.instance
        .collection('userData')
        .where('email', isEqualTo: email)
        .where('uid', isNotEqualTo: uid);

    return doc.snapshots().isEmpty;
  }

  Future<void> requestFriend(String uid, String requesterUID) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'requests': FieldValue.arrayUnion([requesterUID])
    });
  }
  Future<void> deleteRequest(String uid, String requesterUID) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'requests': FieldValue.arrayRemove([requesterUID])
    });
  }

  Future<void> addFriend(String uid, String friendUID) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'friends': FieldValue.arrayUnion([friendUID])
    });
  }
  Future<void> removeFriend(String uid, friendUID) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'friends': FieldValue.arrayRemove([friendUID])
    });
  }

  Future<void> addGroup(String uid, String groupId) async{
    FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'groups': FieldValue.arrayUnion([groupId])
    });
  }

  Future<void> deleteGroup(String uid, String groupId) async{
    FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'groups': FieldValue.arrayRemove([groupId])
    });
  }

  Future<void> addEvent(String uid, String eventId) async{
    FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'events': FieldValue.arrayUnion([eventId])
    });
  }

  Future<void> deleteEvent(String uid, String eventId) async{
    FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'events': FieldValue.arrayRemove([eventId])
    });
  }

  Future<void> addNotification(String uid, String notificationId) async{
    FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'notifications': FieldValue.arrayUnion([notificationId])
    });
  }

  Future<void> addChat(String uid, String chatId) async{
    await FirebaseFirestore.instance.collection('userData')
        .doc(uid)
        .update({
      'chats': FieldValue.arrayUnion([chatId])});
  }
}