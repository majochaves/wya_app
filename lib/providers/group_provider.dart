import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:wya_final/providers/user_provider.dart';
import 'package:wya_final/services/group_service.dart';
import 'package:wya_final/services/user_service.dart';

import '../models/group.dart';
import '../models/user_data.dart';

class GroupProvider extends ChangeNotifier{
  static const Uuid uuid = Uuid();

  ///Constructor
  GroupProvider(){
    init();
  }

  ///ChangeNotifierProxy Update Method: Updates when UserProvider has been updated
  void update(UserProvider provider){
    friendInfo = provider.friendInfo;
    notifyListeners();
  }

  ///Services
  GroupService groupService = GroupService();
  UserService userService = UserService();

  ///Shared data from User Provider
  List<UserData> friendInfo = [];
  List<Group> groups = [];
  Map<Group, List<UserData>> groupMap = {};

  StreamSubscription? getGroupsStream;

  void cancelStreams(){
    getGroupsStream?.cancel();
  }

  void clearData(){
    groups.clear();
    friendInfo.clear();
    groupMap.clear();
    _members.clear();
    _uid = null;
    _groupId = null;
    _name = null;
    notifyListeners();
  }

  ///Get groups from Group Stream
  init(){
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        getGroupsStream = groupService.getGroups(FirebaseAuth.instance.currentUser!.uid).listen((groupList) {
          print('Getting groups stream for user: ${user.uid}');
          groups = groupList;
          notifyListeners();
          groupMap.clear();
          for(Group group in groupList){
            List<UserData> members = getFriendsContainedIn(group.members);
            groupMap.putIfAbsent(group, () => members);
          }
          notifyListeners();
        });
      }else{
        cancelStreams();
        clearData();
        print('group provider: reset');
      }
    });
  }

  ///Provider values
  String? _uid;
  String? _groupId;
  String? _name;
  List<UserData> _members = [];

  String? get uid => _uid;
  set uid(String? value) {
    _uid = value;
    notifyListeners();
  }
  String? get groupId => _groupId;
  set groupId(String? value) {
    _groupId = value;
    notifyListeners();
  }
  String? get name => _name;
  set name(String? value) {
    _name = value;
    notifyListeners();
  }
  List<UserData> get members => _members;
  set members(List<UserData> value) {
    _members = value;
    notifyListeners();
  }

  ///Provider methods
  void addMember(UserData member){
    _members.add(member);
    notifyListeners();
  }
  void removeMember(UserData member){
    _members.remove(member);
    notifyListeners();
  }
  List<UserData> getFriendsContainedIn(List list){
    List<UserData> friendsContainedIn = List.from(friendInfo);
    friendsContainedIn.removeWhere((element) => !list.contains(element.uid));
    return friendsContainedIn;
  }

  ///Sets new group values
  void newGroup(){
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _groupId = null;
    _name = '';
    _members = [];
    notifyListeners();
  }

  void loadGroup(Group group) {
    _groupId = group.groupId;
    _uid = group.uid;
    _name = group.name;
    _members = getFriendsContainedIn(group.members);
  }

  void saveGroup(){
    if(groupId == null){
      groupId = uuid.v1();
      Group newGroup = Group(name: name!, uid: uid!, groupId: groupId!, members: members.map((e) => e.uid).toList());
      groupService.saveGroup(newGroup);
    }else{
      Group updatedGroup = Group(name: name!, uid: uid!, groupId: groupId!, members: members.map((e) => e.uid).toList());
      groupService.updateGroup(updatedGroup);
    }
    userService.addGroup(FirebaseAuth.instance.currentUser!.uid, groupId!);
  }

  void deleteGroup(String groupId) async{
    await groupService.deleteGroup(groupId);
    await userService.deleteGroup(FirebaseAuth.instance.currentUser!.uid, groupId);
  }
  Future<bool> groupNameIsUnique(String groupName, String groupId) async{
    return groupService.groupNameIsUnique(FirebaseAuth.instance.currentUser!.uid, groupName, groupId);
  }

}