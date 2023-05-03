// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/src/calendar.dart';
import 'package:wya_final/src/match_previewer.dart';
import 'package:wya_final/src/shared_event_previewer.dart';
import 'package:wya_final/welcome_page.dart';

import 'app_state.dart';
import 'src/authentication.dart';
import 'src/widgets.dart';
import 'src/date_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final appState = Provider.of<ApplicationState>(context, listen: false);
      appState.selectedDay = DateTime.now();
    });
  }

  Future<void> toggleCalendar() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Date'),
          content: Consumer<ApplicationState>(
              builder: (context, appState, _)
                => SizedBox(height:350, width: 300,
                    child: Calendar(
                      events: appState.sharedEvents.map((e) => e.event).toList(),
                      selectedDay: appState.selectedDay,
                      onSelectDay: (selectedDay) => appState.selectedDay = selectedDay,
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
    return Consumer<ApplicationState>(
        builder: (context, appState, _) => appState.loggedIn ? Scaffold(
        appBar: AppBar(
          title: const Text('WYA'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 8),
                Expanded(child: DateSelector(selectedDay: appState.selectedDay, toggleCalendar: toggleCalendar)),
                const SizedBox(height: 10),
                Expanded(flex: 3, child: MatchPreviewer(matches: appState.matches)),
                const SizedBox(height: 10),
                Expanded(flex: 5, child: SharedEventPreviewer(sharedEvents: appState.sharedEvents)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomAppBarCustom(current: 'home',),
      ) : const WelcomePage(),
    );
  }
}
