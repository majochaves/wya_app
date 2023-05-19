import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'dart:async';

import 'package:wya_final/utils/constants.dart';
import 'package:wya_final/widgets/widgets.dart';

import '../../app_state.dart';
import '../models/user_data.dart';
import '../pages/profile_page.dart';

class AllFriendsViewer extends StatefulWidget {
  final List<UserData> friends;
  final FutureOr<void> Function(String friendId) deleteFriend;
  final String uid;

  const AllFriendsViewer(
      {Key? key,
      required this.uid,
      required this.friends,
      required this.deleteFriend})
      : super(key: key);

  @override
  State<AllFriendsViewer> createState() => _AllFriendsViewerState();
}

class _AllFriendsViewerState extends State<AllFriendsViewer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) =>
      RoundedContainer(
          padding: 10,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'All friends (${appState.friends.length})',
              textAlign: TextAlign.start,
              style: kH3RobotoTextStyle,
            ),
            widget.friends.isNotEmpty
                ? Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: appState.friends.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          child: ListTile(
                            leading: CircleAvi(
                              imageSrc: NetworkImage(
                                appState.friends[index].photoUrl,
                              ),
                              size: 40,
                            ),
                            title: Text(appState.friends[index].username),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                appState.removeFriend(appState.friends[index].uid);
                              },
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(
                                    uid: appState.friends[index].uid,
                                  ),
                                ));
                          },
                        );
                      }),
                )
                : const Expanded(
                    child:
                        Center(child: Text('You have no friends yet. '))),
          ])),
    );
  }
}
