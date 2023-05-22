// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/providers/chat_provider.dart';
import 'package:wya_final/providers/event_provider.dart';
import 'package:wya_final/providers/user_provider.dart';
import '../providers/notification_provider.dart';
import '/widgets/calendar.dart';
import 'package:wya_final/widgets/event_widgets/match_previewer.dart';
import '/widgets/event_widgets/shared_event_previewer.dart';
import 'package:wya_final/utils/constants.dart';

import '/widgets/widgets.dart';
import '../widgets/event_widgets/date_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final eventProvider = Provider.of<EventProvider>(context, listen:false);
      eventProvider.selectedDay = DateTime.now();
    });
  }

  Future<void> toggleCalendar() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Date'),
          content: Consumer<EventProvider>(
              builder: (context, eventProvider, _)
                => SizedBox(height:350, width: 300,
                    child: Calendar(
                      events: eventProvider.sharedEventsForDay(eventProvider.selectedDay).map((e) => e.event).toList(),
                      selectedDay: eventProvider.selectedDay,
                      onSelectDay: (selectedDay) => eventProvider.selectedDay = selectedDay,
                      monthView: true)),),
          actions: <Widget>[
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    return userProvider.isLoading ? const Center(child: CircularProgressIndicator())
        : Scaffold(
              appBar: AppBar(
                backgroundColor: kWYATeal,
                title: Image(image: Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/wyatextorange.png').image, width: 80,),
                actions: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {context.go('/notifications');},
                        child: Stack(
                          children: <Widget>[
                            const Icon(Icons.notifications, color: Colors.white, size: 30,),
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: kWYAOrange,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 12,
                                  minHeight: 12,
                                ),
                                child: Text(
                                  '${notificationProvider.unreadNotifications}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 20,),
                      InkWell(
                        onTap: () {context.go('/chats');},
                        child: Stack(
                          children: <Widget>[
                            const Icon(Icons.send, color: Colors.white, size: 30,),
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: kWYAOrange,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 12,
                                  minHeight: 12,
                                ),
                                child: Text(
                                  '${chatProvider.unreadMessages}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 10,),
                    ],
                  ),
                ],
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      Expanded(child: DateSelector(selectedDay: eventProvider.selectedDay, toggleCalendar: toggleCalendar)),
                      const CustomDivider(),
                      Expanded(flex: 3, child: MatchPreviewer(matches: eventProvider.matchesForDay(eventProvider.selectedDay), uid: userProvider.uid ?? '',)),
                      const CustomDivider(),
                      Expanded(flex: 5, child: SharedEventPreviewer(sharedEvents: eventProvider.sharedEventsForDay(eventProvider.selectedDay), setSelectedSharedEvent: (sharedEvent) => eventProvider.setSelectedSharedEvent(sharedEvent),
                      uid: userProvider.uid ?? '',)),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: const CustomBottomAppBar(current: 'home',),
        );
  }
}
