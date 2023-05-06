import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/app_state.dart';
import 'package:wya_final/src/all_friends_viewer.dart';
import 'package:wya_final/src/requests_viewer.dart';
import 'package:wya_final/src/widgets.dart';
import 'groups_viewer.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) =>
      Scaffold(
        appBar: AppBar(
          title: const Text('WYA'),
        ),
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: RequestsViewer(
                        requests: appState.requests,
                        addFriend: appState.addFriend,
                        deleteRequest: appState.deleteRequest,
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      height: 200,
                      child: GroupsViewer(
                      uid: appState.userData.uid,
                      friends: appState.friends,
                      groups: appState.groups,
                      updateGroup: appState.updateGroup,
                      addGroup: appState.addGroup,
                      deleteGroup: appState.deleteGroup,
                    ),),
                    const SizedBox(height: 10,),
                    SizedBox(
                      height: 500,
                      child: AllFriendsViewer(
                      uid: appState.userData.uid,
                      friends: appState.friends,
                      deleteFriend: appState.removeFriend,
                    ))
                  ],
                ),
              )),
        ),
        bottomNavigationBar: const BottomAppBarCustom(current: 'account'),
      ),
    );
  }
}
