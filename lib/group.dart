import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Group{
  final String uid;
  final String groupId;
  final String name;
  final List members;

  const Group({
    required this.name,
    required this.uid,
    required this.groupId,
    required this.members
  });

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "groupId": groupId,
    "name": name,
    "members": members,
  };

  static Group fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Group(
      name: snapshot['name'],
      uid: snapshot['uid'],
      groupId: snapshot['groupId'],
      members: snapshot['members'],
    );
  }

  static Group emptyGroup(String uid){
    return Group(
      name: '',
      uid: uid,
      groupId: const Uuid().v1(),
      members: [],
    );
  }
}