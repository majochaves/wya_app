import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/app_state.dart';
import '../utils/constants.dart';
import '/src/widgets/all_friends_viewer.dart';
import '/src/widgets/requests_viewer.dart';
import '/src/widgets/widgets.dart';

import 'groups_viewer.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) =>
      Scaffold(
        appBar: const AppBarCustom(),
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  RequestsViewer(
                    requests: appState.requests,
                    addFriend: appState.addFriend,
                    deleteRequest: appState.deleteRequest,
                  ),
                  const SizedBox(height: 10,),
                  Expanded(
                    flex: 6,
                      child: AllFriendsViewer(
                        uid: appState.userData.uid,
                        friends: appState.friends,
                        deleteFriend: appState.removeFriend,
                      )),
                  const SizedBox(height: 10,),
                  InkWell(
                    onTap: () {context.go('/groups');},
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text(
                        'My groups',
                        style: kH3RobotoTextStyle,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          context.go('/groups');
                        },
                      ),
                    ]),
                  ),
                ],
              )),
        ),
        bottomNavigationBar: const BottomAppBarCustom(current: 'account'),
      ),
    );
  }
}
