import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/group.dart';

class GroupManager{
  GroupManager();

  Future<void> addGroup(Group group) async{
    await FirebaseFirestore.instance.collection('groups').doc(group.groupId).set(group.toJson());
  }
  Future<void> updateGroup(Group group) async{
    await FirebaseFirestore.instance.collection('groups').doc(group.groupId).update(group.toJson());
  }
  Future<void> deleteGroup(String groupId) async{
    await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
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
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .update({
      'members': FieldValue.arrayRemove(oldFriends),
    });
  }
}