//Core
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/src/utils/constants.dart';
import 'package:wya_final/src/widgets.dart';
import 'app_state.dart';
import 'src/utils/utils.dart';


class ProfilePage extends StatefulWidget {
  final String? uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
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
          .collection('users')
          .doc(widget.uid)
          .get();

      // get post lENGTH
      var eventSnap = await FirebaseFirestore.instance
          .collection('events')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      setState(() {
        eventsLen = eventSnap.docs.length;
        userData = userSnap.data()!;
        friends = userSnap.data()!['friends'].length;
        isFriend = userSnap
            .data()!['friends']
            .contains(FirebaseAuth.instance.currentUser!.uid);
        isRequested = userSnap.data()!['requests']
            .contains(FirebaseAuth.instance.currentUser!.uid);
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
    return isLoading
        ? const Center(
      child: CircularProgressIndicator(),
    )
        : Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: const Text(
              'wya',
            ),),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(flex: 1, child: Column(children: <Widget>[
                CircleAvi(
                  imageSrc: NetworkImage(
                    userData['photoUrl'],
                  ),
                  size: 100,
                ),
                const SizedBox(height: 5,),
                Text(
                  '@${userData['username']}',
                  style: kHandleTextStyle,
                ),
                const SizedBox(height: 5,),
                Text(
                  userData['name'],
                  style: kNameStyle,
                ),
                const SizedBox(height: 5,),
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: kPastelOrangeYellow
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                    top: 1,
                  ),
                  child: Text(
                    userData['bio'],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              StatColumn(num: eventsLen, label: "events", pushTo: (){}),
                              StatColumn(num: friends, label: "friends", pushTo: (){}),
                            ],
                          ),
                          Consumer<ApplicationState>(
                            builder: (context, appState, _) => Row( children: [isFriend
                                    ? FollowButton(
                                  text: 'Remove friend',
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  borderColor: Colors.grey,
                                  function: () {
                                    appState.removeFriend(userData['uid']);
                                    setState(() {
                                      isFriend = false;
                                      friends--;
                                    });
                                  },
                                )
                                    : isRequested ?
                                FollowButton(
                                    text: 'Requested',
                                    backgroundColor: Colors.grey,
                                    textColor: Colors.black54,
                                    borderColor: Colors.grey,
                                    function: () {}) :
                                FollowButton(
                                  text: 'Add friend',
                                  backgroundColor: Colors.blue,
                                  textColor: Colors.white,
                                  borderColor: Colors.blue,
                                  function: () {
                                    appState.requestFriend(userData['uid']);
                                    setState(() {
                                      isRequested = true;
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],)),
            ],
          ),
        ),
        bottomNavigationBar: const BottomAppBarCustom(current: 'search',),
    );
  }
}
