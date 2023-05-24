import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../widgets.dart';

class UserDetailsViewer extends StatelessWidget {
  final String photoUrl;
  final String username;
  final String name;
  final int friendsCount;
  final int eventsCount;
  final bool isUserAccount;
  const UserDetailsViewer({Key? key, required this.photoUrl, required this.username, required this.name, required this.friendsCount, required this.eventsCount, required this.isUserAccount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20,),
        Expanded(
          flex: 4,
          child: CircleAvatar(
            radius: 50.0,
            backgroundColor: Colors.transparent,
            backgroundImage: photoUrl.isNotEmpty ? Image.network(
              photoUrl,
            ).image : Image.asset('assets/images/noProfilePic.png').image,
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '@$username',
                style: kHandleTextStyle,
              ),
            ],
          ),
        ),
        Visibility(
          visible: name.isNotEmpty,
          child: Expanded(
            flex: 2,
            child:
            Text(
              name,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatColumn(num: eventsCount, label: "events", pushTo: '/events', isEnabled: isUserAccount),
              StatColumn(num: friendsCount, label: "friends", pushTo: '/friends', isEnabled: isUserAccount),
            ],
          ),
        ),
      ],
    );
  }
}