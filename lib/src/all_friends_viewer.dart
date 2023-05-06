import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'dart:async';

import 'package:wya_final/src/utils/constants.dart';
import 'package:wya_final/src/widgets.dart';

import '../user_data.dart';

class AllFriendsViewer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return RoundedContainer(
        padding: 10,
        backgroundColor: kPastelBlue,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'All friends (${friends.length})',
            textAlign: TextAlign.start,
            style: kH3RobotoTextStyle,
          ),
          friends.isNotEmpty
              ? Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        child: ListTile(
                          leading: CircleAvi(
                            imageSrc: NetworkImage(
                              friends[index].photoUrl,
                            ),
                            size: 40,
                          ),
                          title: Text(friends[index].username),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              deleteFriend(friends[index].uid);
                            },
                          ),
                        ),
                        onTap: () {
                          context.push('profile:${friends[index].uid}');
                        },
                      );
                    }),
              )
              : const Expanded(
                  child:
                      Center(child: Text('You have no friends yet. '))),
        ]));
  }
}
