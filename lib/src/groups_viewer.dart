import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wya_final/src/utils/constants.dart';
import 'package:wya_final/src/widgets.dart';

import '../group.dart';
import '../user_data.dart';

class GroupsViewer extends StatefulWidget {
  final Map<Group, List<UserData>> groups;
  final List<UserData> friends;
  final FutureOr<void> Function(String groupId) deleteGroup;
  final FutureOr<void> Function(Group group) addGroup;
  final String uid;

  const GroupsViewer(
      {Key? key,
      required this.groups,
      required this.deleteGroup,
      required this.addGroup,
      required this.uid,
      required this.friends})
      : super(key: key);

  @override
  State<GroupsViewer> createState() => _GroupsViewerState();
}

class _GroupsViewerState extends State<GroupsViewer> {
  final _groupNameFormKey =
      GlobalKey<FormState>(debugLabel: '_GroupPageStateNameForm');
  late TextEditingController _groupNameController = TextEditingController();
  List<UserData> selectedFriends = [];

  Future<void> viewGroupWidget(
      Group group, List<UserData> members, bool isNewGroup) async {
    bool isChangeGroup = isNewGroup;
    _groupNameController.text = group.name;
    String error = '';
    List<UserData> friendsNotInGroup = widget.friends;
    friendsNotInGroup.removeWhere((element) => members.contains(element));
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return widget.friends.isEmpty
            ? AlertDialog(
                content: const SizedBox(
                  height: 100,
                  width: 300,
                  child: Center(
                    child:
                        Text('You have no friends. Add friends to make groups'),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Done'),
                    onPressed: () {
                      _groupNameController.clear();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            : AlertDialog(
                content: SizedBox(
                  height: 350,
                  width: 300,
                  child: Column(
                    children: [
                      Visibility(
                        visible: isChangeGroup,
                        child: Row(
                          children: [
                            Form(
                              key: _groupNameFormKey,
                              child: TextFormField(
                                controller: _groupNameController,
                                decoration: const InputDecoration(
                                  hintText: 'Group name',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Group name must not be empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () {
                                if (_groupNameFormKey.currentState!
                                    .validate()) {
                                  group = Group(
                                    groupId: group.groupId,
                                    name: _groupNameController.text,
                                    uid: group.uid,
                                    members: group.members,
                                  );
                                  error = '';
                                  isChangeGroup = false;
                                }
                              },
                            ),
                            IconButton(
                                onPressed: () {
                                  error = '';
                                  isChangeGroup = false;
                                },
                                icon: Icon(Icons.close))
                          ],
                        ),
                      ),
                      Visibility(
                        visible: !isChangeGroup,
                        child: Row(children: [
                          Text(group.name),
                          IconButton(
                              onPressed: () {
                                isChangeGroup = true;
                              },
                              icon: const Icon(Icons.edit)),
                          TextButton(
                            onPressed: () {
                              widget.deleteGroup(group.groupId);
                            },
                            child: const Text('Delete group'),
                          )
                        ]),
                      ),
                      const Text('Members: '),
                      SizedBox(
                        height: 100,
                        child: members.isEmpty
                            ? const Center(
                                child: Text(
                                    'Your group has no members yet. Add a friend.'),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: members.length,
                                itemBuilder: (context, index) {
                                  ListTile(
                                    leading: CircleAvi(
                                      imageSrc: NetworkImage(
                                        members[index].photoUrl,
                                      ),
                                      size: 40,
                                    ),
                                    title: Text(members[index].username),
                                    trailing: IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        group.members
                                            .remove(members[index].uid);
                                        members.remove(members[index]);
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Add Friends:'),
                      SizedBox(
                        height: 100,
                        child: friendsNotInGroup.isEmpty
                            ? const Center(
                                child: Text(
                                    "You've added all your friends to this grouo."),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: friendsNotInGroup.length,
                                itemBuilder: (context, index) {
                                  ListTile(
                                    leading: CircleAvi(
                                      imageSrc: NetworkImage(
                                        friendsNotInGroup[index].photoUrl,
                                      ),
                                      size: 40,
                                    ),
                                    title:
                                        Text(friendsNotInGroup[index].username),
                                    trailing: IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        group.members
                                            .add(friendsNotInGroup[index].uid);
                                        members.add(friendsNotInGroup[index]);
                                        friendsNotInGroup.removeAt(index);
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                      SizedBox(
                        height: 30,
                        child: Text(error),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      _groupNameController.clear();
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Done'),
                    onPressed: () {
                      if (group.members.isEmpty) {
                        error = 'Group must have at least one member.';
                      } else if (group.name.isEmpty) {
                        error = 'Group name must not be empty';
                      } else {
                        widget.addGroup(group);
                        _groupNameController.clear();
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
        padding: 10,
        backgroundColor: kPastelBlue,
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Groups (${widget.groups.length})', style: kH3TextStyle,),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                viewGroupWidget(Group.emptyGroup(widget.uid), [], true);
              },
            ),
          ]),
          widget.groups.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: widget.groups.length,
                  itemBuilder: (context, index) {
                    InkWell(child: ListTile(title: Text(widget.groups.keys.elementAt(index).name),),
                    onTap: () {viewGroupWidget(widget.groups.keys.elementAt(index), widget.groups[index]!, false);},);
                  })
              : const Expanded(child: Center(child: Text('You have no groups yet. Add one. '))),
        ]));
  }
}
