import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/group.dart';
import '../models/user_data.dart';

class GroupService{
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  Stream<List<Group>> getGroups(String uid){
    return _db
        .collection('groups')
        .where('uid', isEqualTo: uid)
        .snapshots().map((snapshot) =>
        snapshot.docs
            .map((document) => Group.fromSnap(document))
            .toList());
  }

  Future<void> saveGroup(Group group) async{
    await _db.collection('groups').doc(group.groupId).set(group.toJson());
  }
  Future<void> updateGroup(Group group) async{
    await _db.collection('groups').doc(group.groupId).update(group.toJson());
  }
  Future<void> deleteGroup(String groupId) async{
    await _db.collection('groups').doc(groupId).delete();
  }

  bool groupNameIsUnique(String uid, String groupName, String groupId){
    bool isUnique = false;
    FirebaseFirestore.instance
        .collection('groups')
        .where('uid', isEqualTo: uid)
        .where('groupId', isNotEqualTo: groupId)
        .where('name', isEqualTo: groupName)
        .snapshots()
        .listen((snapshot) {
      if(snapshot.docs.isNotEmpty){
        isUnique = false;
      }else{
        isUnique = true;
      }
    });
    return isUnique;
  }

  Future<void> removeOldFriends(String groupId, List oldFriends) async {
    await _db
        .collection('groups')
        .doc(groupId)
        .update({
      'members': FieldValue.arrayRemove(oldFriends),
    });
    Group group = Group.fromSnap(await _db
        .collection('groups')
        .doc(groupId).get());
    if(group.members.isEmpty){
      deleteGroup(groupId);
    }
  }

  Future<void> removeFriendFromUserGroups(String userId, String friendId) async {
    Query doc = _db
        .collection('groups')
        .where('uid', isEqualTo: userId)
        .where('members', arrayContains: friendId);

    doc.get().then((value) => value.docs.forEach((element) {
      Group group = Group.fromSnap(element);
      removeOldFriends(group.groupId, [friendId]);
    }));

    Query doc2 = _db
        .collection('groups')
        .where('uid', isEqualTo: friendId)
        .where('members', arrayContains: userId);

    doc2.get().then((value) => value.docs.forEach((element) {
      Group group = Group.fromSnap(element);
      removeOldFriends(group.groupId, [userId]);
    }));
  }

  Future<void> removeUserFromAllGroups(String uid) async{
    await _db
        .collection('groups')
        .where('members', arrayContains: uid)
        .get().then((value) => value.docs.forEach((element) {
      Group group = Group.fromSnap(element);
      removeOldFriends(group.groupId, [uid]);
    }));
  }

  Future<void> deleteAllUserGroups(String uid) async{
    await _db
        .collection('groups')
        .where('uid', isEqualTo: uid)
        .get().then((value) => value.docs.forEach((element) {
      Group group = Group.fromSnap(element);
      deleteGroup(group.groupId);
    }));
  }
}