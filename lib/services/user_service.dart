import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_data.dart';

class UserService {
  UserService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  ///Streams
  Stream<UserData?> getUserData(String uid){
    return FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .snapshots().map((snapshot) => UserData.fromSnap(snapshot));
  }
  Stream<List<UserData>> getUserFriends(String uid){
    return FirebaseFirestore.instance
        .collection('userData')
        .where('friends', arrayContains: uid)
        .snapshots().map((snapshot) =>
        snapshot.docs
            .map((document) => UserData.fromSnap(document))
            .toList());
  }

  Stream<List<UserData>> getUserRequests(String uid){
    return FirebaseFirestore.instance
        .collection('userData')
        .where('pendingRequests', arrayContains: uid)
        .snapshots().map((snapshot) =>
        snapshot.docs
            .map((document) => UserData.fromSnap(document))
            .toList());
  }

  ///Get UserData from database
  Future<UserData> getUserById(String uid) async{
    DocumentSnapshot userSnap = await FirebaseFirestore.instance.collection('userData').doc(uid).get();
    return UserData.fromSnap(userSnap);
  }

  ///Save UserData to database
  Future<void> saveUserData(UserData user) {
    return _db
        .collection('userData')
        .doc(user.uid)
        .set(user.toJson());
  }

  ///Delete UserData from database
  Future<void> deleteUserData(String uid) {
    return _db
        .collection('userData')
        .doc(uid)
        .delete();
  }

  ///Queries
  Future<bool> userDataExists(String uid) async {
    try{
      QuerySnapshot doc = await _db
          .collection('userData')
          .where('uid', isEqualTo: uid)
          .get();
      return doc.docs.isNotEmpty;
    } catch(e){
      print('error is here');
    }
    return false;
  }
  Future<bool> emailIsUnique(String email, String uid) async{
    Query doc = FirebaseFirestore.instance
        .collection('userData')
        .where('email', isEqualTo: email)
        .where('uid', isNotEqualTo: uid);

    return doc.snapshots().isEmpty;
  }

  ///Data update methods
  /*Update: email */
  Future<void> changeEmail(String email, String uid) {
    return FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'email': email
    });
  }

  /*Update: name */
  Future<void> changeName(String name, String uid) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'name': name
    });
  }

  /*Update: username */
  Future<void> changeUsername(String username, String uid) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'username': username
    });
  }

  /*Update: allowAdd */
  Future<void> changeAllowAdd(bool value, String uid) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'allowAdd': value
    });
  }
  /*Update: maxMatchDistance */
  Future<void> changeMaxMatchDistance(double value, String uid) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'maxMatchDistance': value.toInt()
    });
  }

  /*Update: photoUrl */
  Future<void> changeProfilePicture(String photoUrl, String uid) async{
    await FirebaseFirestore.instance.collection('userData').doc(uid).update({'photoUrl' : photoUrl});
  }

  /*Update: add request to requests */
  Future<void> requestFriend(String uid, String requesterUID) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(requesterUID)
        .update({
        'pendingRequests': FieldValue.arrayUnion([uid])
        });
    return await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'requests': FieldValue.arrayUnion([requesterUID])
    });
  }

  /*Update: remove request from requests */
  Future<void> deleteRequest(String uid, String requesterUID) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(requesterUID)
        .update({
      'pendingRequests': FieldValue.arrayRemove([uid])
    });
    return await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
          'requests': FieldValue.arrayRemove([requesterUID])
        });
  }

  /*Update: add friend to friends */
  Future<void> addFriend(String uid, String requesterUID) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(requesterUID)
        .update({
      'friends': FieldValue.arrayUnion([uid])
    });
    return await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'friends': FieldValue.arrayUnion([requesterUID])
    });
  }

  /*Update: remove friend from friends */
  Future<void> removeFriend(String uid, friendUID) async{
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(friendUID)
        .update({
      'friends': FieldValue.arrayRemove([uid])
    });
    return await FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
          'friends': FieldValue.arrayRemove([friendUID])
        });
  }
  
  Future<void> removeUserFromUserData(String uid) async{
    await _db
        .collection('userData')
        .where('friends', arrayContains: uid)
        .get().then((value) => value.docs.forEach((element) {
      UserData user = UserData.fromSnap(element);
      removeFriend(user.uid, uid);
    }));
    await _db
        .collection('userData')
        .where('pendingRequests', arrayContains: uid)
        .get().then((value) => value.docs.forEach((element) {
      UserData user = UserData.fromSnap(element);
      deleteRequest(user.uid, uid);
    }));
  }

  /*Update: add group to groups */
  Future<void> addGroup(String uid, String groupId) async{
    FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'groups': FieldValue.arrayUnion([groupId])
    });
  }

  /*Update: delete group from groups */
  Future<void> deleteGroup(String uid, String groupId) async{
    FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'groups': FieldValue.arrayRemove([groupId])
    });
  }

  /*Update: add event to events */
  Future<void> addEvent(String uid, String eventId) async{
    FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'events': FieldValue.arrayUnion([eventId])
    });
  }

  /*Update: delete event from events */
  Future<void> deleteEvent(String uid, String eventId) async{
    FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'events': FieldValue.arrayRemove([eventId])
    });
  }

  /*Update: add notification to notifications */
  Future<void> addNotification(String uid, String notificationId) async{
    FirebaseFirestore.instance
        .collection('userData')
        .doc(uid)
        .update({
      'notifications': FieldValue.arrayUnion([notificationId])
    });
  }

  /*Update: add chat to chats */
  Future<void> addChat(String uid, String chatId) async{
    await FirebaseFirestore.instance.collection('userData')
        .doc(uid)
        .update({
      'chats': FieldValue.arrayUnion([chatId])});
  }
}