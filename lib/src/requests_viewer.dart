import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wya_final/src/utils/constants.dart';
import 'package:wya_final/src/widgets.dart';

import '../user_data.dart';

class RequestsViewer extends StatefulWidget {

  final FutureOr<void> Function(String uid) addFriend;
  final FutureOr<void> Function(String uid) deleteRequest;

  final List<UserData> requests;
  const RequestsViewer({Key? key, required this.requests, required this.addFriend, required this.deleteRequest}) : super(key: key);

  @override
  State<RequestsViewer> createState() => _RequestsViewerState();
}

class _RequestsViewerState extends State<RequestsViewer> {
  bool viewRequests = false;

  void selectViewRequests(bool viewRequestsBool) {
    setState(() {
      viewRequests = viewRequestsBool;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      padding: 10,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Row(children: [
            Text('Requests (${widget.requests.length})', style: kH3RobotoTextStyle,),
            Visibility(
                visible: widget.requests.isNotEmpty,
                child: IconButton(
                  icon: const Icon(Icons.arrow_drop_down_outlined),
                  onPressed: () {
                    selectViewRequests(true);
                  },
                )),
          ]),
          Visibility(
            visible: viewRequests,
            child: SizedBox(
              height: 160,
              child: Column(
                children: [
                  ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: widget.requests.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => context.push(
                              '/profile:${widget.requests[index].uid}'),
                          child: ListTile(
                            leading: CircleAvi(
                              imageSrc: NetworkImage(
                                widget.requests[index].photoUrl,
                              ),
                              size: 40,
                            ),
                            title: Text(
                              widget.requests[index].username,
                            ),
                            trailing: FittedBox(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check,
                                      size: 25,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      widget.addFriend(
                                          widget.requests[index].uid);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 25,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      widget.deleteRequest(
                                          widget.requests[index].uid);
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                  Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_up_outlined),
                      onPressed: () {
                        selectViewRequests(false);
                      },
                    )
                  ],)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
