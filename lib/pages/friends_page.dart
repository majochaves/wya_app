import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/providers/user_provider.dart';
import '../utils/constants.dart';
import '/widgets/all_friends_viewer.dart';
import '/widgets/requests_viewer.dart';
import '/widgets/widgets.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, _) =>
      Scaffold(
        appBar: const AppBarCustom(),
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  RequestsViewer(
                    requests: userProvider.requestInfo,
                    addFriend: userProvider.addFriend,
                    deleteRequest: userProvider.removeRequest,
                  ),
                  const SizedBox(height: 10,),
                  Expanded(
                    flex: 6,
                      child: AllFriendsViewer(
                        uid: userProvider.uid!,
                        friends: userProvider.friendInfo,
                        deleteFriend: userProvider.removeFriend,
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
