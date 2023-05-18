import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/src/utils/constants.dart';
import 'package:wya_final/src/widgets/widgets.dart';

import '../../app_state.dart';
import '../models/user_data.dart';

class RequestsViewer extends StatefulWidget {

  final FutureOr<void> Function(String uid) addFriend;
  final FutureOr<void> Function(String uid) deleteRequest;

  final List<UserData> requests;
  const RequestsViewer({Key? key, required this.requests, required this.addFriend, required this.deleteRequest}) : super(key: key);

  @override
  State<RequestsViewer> createState() => _RequestsViewerState();
}

class _RequestsViewerState extends State<RequestsViewer> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) =>
      RoundedContainer(
        padding: 10,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Friend requests (${appState.requests.length})', style: kH3RobotoTextStyle,
            textAlign: TextAlign.start,),
            Visibility(
              visible: appState.requests.isNotEmpty,
              child: SizedBox(
                height: 120,
                child: Row(
                  children: [
                    ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: appState.requests.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () => context.push(
                                '/profile:${appState.requests[index].uid}'),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      appState.requests[index].photoUrl,
                                    ),
                                    radius: 25,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      appState.requests[index].username,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      IconButton(
                                        icon: const Icon(
                                          Icons.check,
                                          size: 20,
                                          color: Colors.green,
                                        ),
                                        onPressed: () {
                                          appState.addFriend(
                                              appState.requests[index].uid);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          appState.deleteRequest(
                                              appState.requests[index].uid);
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          );
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
