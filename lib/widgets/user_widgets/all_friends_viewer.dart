import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/providers/user_provider.dart';

import 'dart:async';

import 'package:wya_final/utils/constants.dart';
import 'package:wya_final/widgets/widgets.dart';

import '../../models/user_data.dart';
import '../../screens/profile_screen.dart';

class AllFriendsViewer extends StatefulWidget {
  const AllFriendsViewer(
      {Key? key,})
      : super(key: key);

  @override
  State<AllFriendsViewer> createState() => _AllFriendsViewerState();
}

class _AllFriendsViewerState extends State<AllFriendsViewer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, _) =>
      RoundedContainer(
          padding: 10,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'All friends (${userProvider.friendInfo.length})',
              textAlign: TextAlign.start,
              style: kH3RobotoTextStyle,
            ),
            userProvider.friendInfo.isNotEmpty
                ? Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: userProvider.friendInfo.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          child: ListTile(
                            leading: CircleAvi(
                              imageSrc: NetworkImage(
                                userProvider.friendInfo[index].photoUrl,
                              ),
                              size: 40,
                            ),
                            title: Text(userProvider.friendInfo[index].username),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                userProvider.removeFriend(userProvider.friendInfo[index]);
                              },
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                    uid: userProvider.friendInfo[index].uid,
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
