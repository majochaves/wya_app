import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/utils/constants.dart';
import 'package:wya_final/widgets/widgets.dart';

import '../../app_state.dart';
import '../models/group.dart';
import '../models/user_data.dart';

class GroupsViewer extends StatefulWidget {
  const GroupsViewer(
      {Key? key,})
      : super(key: key);

  @override
  State<GroupsViewer> createState() => _GroupsViewerState();
}

class _GroupsViewerState extends State<GroupsViewer> {
  final _groupNameFormKey =
      GlobalKey<FormState>(debugLabel: '_GroupPageStateNameForm');
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _errorController = TextEditingController();
  List<UserData> selectedFriends = [];

  Future<void> viewGroupWidget(
      Group group, List<UserData> members, bool isNewGroup, List<UserData> friends) async {
    final appState = Provider.of<ApplicationState>(context, listen: false);
    bool isChangeGroup = isNewGroup;
    _groupNameController.text = group.name;
    _errorController.text = '';
    List<UserData> friendsNotInGroup = List<UserData>.from(friends);
    friendsNotInGroup.removeWhere((element) => members.contains(element));

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return friends.isEmpty
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
                content: Consumer<ApplicationState>(
                  builder: (context, appState, _) => StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return SizedBox(
                      height: 450,
                      width: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Visibility(
                            visible: isChangeGroup,
                            child: Expanded(
                              child: Form(
                                key: _groupNameFormKey,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
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
                                    )),
                                    IconButton(
                                      icon: const Icon(Icons.check),
                                      onPressed: () {
                                        if (_groupNameFormKey.currentState!
                                            .validate()) {
                                          setState(() {
                                            group = Group(
                                              groupId: group.groupId,
                                              name: _groupNameController.text,
                                              uid: group.uid,
                                              members: group.members,
                                            );
                                            _errorController.text = '';
                                            isChangeGroup = false;
                                          });
                                        }
                                      },
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _errorController.text = '';
                                            isChangeGroup = false;
                                          });
                                        },
                                        icon: const Icon(Icons.close)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: !isChangeGroup,
                            child: Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(child: Text(group.name)),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isChangeGroup = true;
                                        });
                                      },
                                      icon: const Icon(Icons.edit)),
                                  Visibility(
                                    visible: !isNewGroup,
                                    child: TextButton(
                                      onPressed: () {
                                        appState.deleteGroup(group.groupId);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Delete group'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                            width: 300,
                          ),
                          const Text(
                            'Members: ',
                            style: kH3SourceSansTextStyle,
                          ),
                          const SizedBox(
                            height: 10,
                            width: 300,
                          ),
                          Expanded(
                            flex: 4,
                            child: members.isEmpty
                                ? const Center(
                                    child: Text(
                                        'Your group has no members yet. Add a friend.'),
                                  )
                                : UserListTiles(
                                    users: members,
                                    icon: Icons.close,
                                    onPressed: (user) {
                                      setState(() {
                                        group.members.remove(user.uid);
                                        members.remove(user);
                                        friendsNotInGroup.add(user);
                                      });
                                    }),
                          ),
                          const SizedBox(
                            height: 10,
                            width: 300,
                          ),
                          const Text('Add Friends:',
                              style: kH3SourceSansTextStyle),
                          const SizedBox(
                            height: 10,
                            width: 300,
                          ),
                          Expanded(
                            flex: 4,
                            child: friendsNotInGroup.isEmpty
                                ? const Center(
                                    child: Text(
                                        "You've added all your friends to this group."),
                                  )
                                : UserListTiles(
                                    users: friendsNotInGroup,
                                    icon: Icons.add,
                                    onPressed: (user) {
                                      setState(() {
                                        group.members.add(user.uid);
                                        members.add(user);
                                        friendsNotInGroup.remove(user);
                                      });
                                    }),
                          ),
                          SizedBox(
                            height: 20,
                            width: 300,
                            child: TextField(
                              style: TextStyle(color: Colors.red.shade700),
                              controller: _errorController,
                              readOnly: true,
                              enabled: false,
                              decoration: const InputDecoration(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
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
                        setState(() {
                          _errorController.text =
                              'Group must have at least one member.';
                        });
                      } else if (group.name.isEmpty) {
                        setState(() {
                          _errorController.text =
                              'Group name must not be empty';
                        });
                      } else {
                        if (isNewGroup) {
                          appState.addGroup(group);
                        } else {
                          appState.updateGroup(group);
                        }

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
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => Scaffold(
        appBar: const AppBarCustom(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  'My groups (${appState.groups.length})',
                  style: kH3RobotoTextStyle,
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: kWYAOrange,),
                  onPressed: () {
                    viewGroupWidget(Group.emptyGroup(appState.userData.uid), [], true, appState.friends);
                  },
                ),
              ]),
              appState.groups.isNotEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: appState.groups.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          child: ListTile(
                            title:
                                Text(appState.groups.keys.elementAt(index).name),
                          ),
                          onTap: () {
                            viewGroupWidget(appState.groups.keys.elementAt(index),
                                appState.groups.values.elementAt(index), false, appState.friends);
                          },
                        );
                      })
                  : const Expanded(
                      child: Center(
                          child: Text('You have no groups yet. Add one. '))),
            ]),
          ),
        ),
        bottomNavigationBar: const BottomAppBarCustom(current: 'account'),
      ),
    );
  }
}
