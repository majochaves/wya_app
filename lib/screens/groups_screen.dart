import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/providers/group_provider.dart';
import 'package:wya_final/providers/user_provider.dart';
import 'package:wya_final/utils/constants.dart';
import 'package:wya_final/widgets/widgets.dart';

import '../models/user_data.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen(
      {Key? key,})
      : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _groupNameFormKey =
      GlobalKey<FormState>(debugLabel: '_GroupPageStateNameForm');
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _errorController = TextEditingController();
  List<UserData> selectedFriends = [];

  Future<void> viewGroupWidget(bool isNewGroup) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    bool isChangeGroup = isNewGroup;
    _groupNameController.text = groupProvider.name!;
    _errorController.text = '';
    List<UserData> friendsNotInGroup = List<UserData>.from(userProvider.friendInfo);
    friendsNotInGroup.removeWhere((element) => groupProvider.members.contains(element));

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return userProvider.friendInfo.isEmpty
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
                content: Consumer<GroupProvider>(
                  builder: (context, groupProvider, _) => StatefulBuilder(
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
                                          groupProvider.name = _groupNameController.text;
                                          setState(() {
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
                                  Expanded(child: Text(groupProvider.name!)),
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
                                        groupProvider.deleteGroup(groupProvider.groupId!);
                                        groupProvider.newGroup();
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
                            child: groupProvider.members.isEmpty
                                ? const Center(
                                    child: Text(
                                        'Your group has no members yet. Add a friend.'),
                                  )
                                : UserListTiles(
                                    users: groupProvider.members,
                                    icon: Icons.close,
                                    onPressed: (user) {
                                      setState(() {
                                        groupProvider.removeMember(user);
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
                                        groupProvider.addMember(user);
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
                      if (groupProvider.members.isEmpty) {
                        setState(() {
                          _errorController.text =
                              'Group must have at least one member.';
                        });
                      } else if (groupProvider.name!.isEmpty) {
                        setState(() {
                          _errorController.text =
                              'Group name must not be empty';
                        });
                      } else {
                        groupProvider.saveGroup();
                        groupProvider.newGroup();
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
    final groupProvider = Provider.of<GroupProvider>(context);
    return Scaffold(
      appBar: const AppBarCustom(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                'My groups (${groupProvider.groups.length})',
                style: kH3RobotoTextStyle,
              ),
              IconButton(
                icon: const Icon(Icons.add, color: kWYAOrange,),
                onPressed: () {
                  groupProvider.newGroup();
                  viewGroupWidget(true);
                },
              ),
            ]),
            groupProvider.groups.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: groupProvider.groups.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        child: ListTile(
                          title: Text(groupProvider.groups.elementAt(index).name),
                        ),
                        onTap: () {
                          groupProvider.loadGroup(groupProvider.groups.elementAt(index));
                          viewGroupWidget(false);
                        },
                      );
                    })
                : const Expanded(
                    child: Center(
                        child: Text('You have no groups yet. Add one. '))),
          ]),
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(current: 'account'),
      );
  }
}
