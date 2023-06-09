import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/providers/user_provider.dart';
import 'package:wya_final/utils/constants.dart';
import 'package:wya_final/utils/utils.dart';
import 'package:wya_final/widgets/user_widgets/user_details_viewer.dart';
import 'package:wya_final/widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  final String? userUID;
  const ProfileScreen({super.key, required this.userUID});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String currentUserUID = FirebaseAuth.instance.currentUser!.uid;
  var userData = {};
  int eventsLen = 0;
  int friends = 0;
  bool isFriend = false;
  bool isRequested = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('userData')
          .doc(widget.userUID)
          .get();

      setState(() {
        eventsLen = userSnap.data()!['events'].length;
        userData = userSnap.data()!;
        print("got user data for user: ${userSnap.data()!['uid']}");
        friends = userSnap.data()!['friends'].length;
        isFriend = userSnap
            .data()!['friends']
            .contains(currentUserUID);
        print('user is friend : ${isFriend.toString()}');
        isRequested = userSnap
            .data()!['requests']
            .contains(currentUserUID);
        print('user is requested : ${isRequested.toString()}');
      });
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: const AppBarCustom(),
            body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: UserDetailsViewer(
                          photoUrl: userData['photoUrl'],
                          username: userData['username'],
                          name: userData['name'],
                          friendsCount: friends,
                          eventsCount: eventsLen,
                          isUserAccount: false),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isFriend
                                  ? FollowButton(
                                      text: 'Remove friend',
                                      backgroundColor: kWYAOrange,
                                      textColor: Colors.black,
                                      borderColor: kWYAOrange,
                                      function: () {
                                        userProvider.removeFriend(userData['uid']);
                                        setState(() {
                                          isFriend = false;
                                          friends--;
                                        });
                                      },
                                    )
                                  : isRequested
                                      ? FollowButton(
                                          text: 'Requested',
                                          backgroundColor: Colors.grey,
                                          textColor: Colors.black54,
                                          borderColor: Colors.grey,
                                          function: () {})
                                      : FollowButton(
                                          text: 'Add friend',
                                          backgroundColor: kWYAOrange,
                                          textColor: Colors.white,
                                          borderColor: kWYAOrange,
                                          function: () {
                                            userProvider.sendFriendRequest(
                                                userData['uid'] as String);
                                            setState(() {
                                              isRequested = true;
                                            });
                                          },
                                        )
                            ],
                          ),
                          Expanded(child: Container()),
                        ],
                      ),
                    ),
                  ],
                )),
            bottomNavigationBar: const CustomBottomAppBar(
              current: 'search',
            ),
          );
  }
}
