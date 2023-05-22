import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../widgets/user_widgets/all_friends_viewer.dart';
import '../widgets/user_widgets/requests_viewer.dart';
import '/widgets/widgets.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const RequestsViewer(),
                const SizedBox(height: 10,),
                const Expanded(
                  flex: 6,
                    child: AllFriendsViewer()),
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
      bottomNavigationBar: const CustomBottomAppBar(current: 'account'),
    );
  }
}
