import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/utils/constants.dart';
import 'package:wya_final/widgets/widgets.dart';

import '../../providers/user_provider.dart';

class RequestsViewer extends StatefulWidget {

  const RequestsViewer({Key? key,}) : super(key: key);

  @override
  State<RequestsViewer> createState() => _RequestsViewerState();
}

class _RequestsViewerState extends State<RequestsViewer> {

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return RoundedContainer(
      padding: 10,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Friend requests (${userProvider.requestInfo.length})', style: kH3RobotoTextStyle,
          textAlign: TextAlign.start,),
          Visibility(
            visible: userProvider.requestInfo.isNotEmpty,
            child: SizedBox(
              height: 120,
              child: Row(
                children: [
                  ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: userProvider.requestInfo.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => context.push(
                              '/profile:${userProvider.requestInfo[index].uid}'),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 2,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    userProvider.requestInfo[index].photoUrl,
                                  ),
                                  radius: 25,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    userProvider.requestInfo[index].username,
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
                                        setState(() {
                                          userProvider.addFriend(
                                              userProvider.requestInfo[index]);
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          userProvider.removeRequest(
                                              userProvider.requestInfo[index]);
                                        });
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
    );
  }
}
