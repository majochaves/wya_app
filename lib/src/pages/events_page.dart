import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/app_state.dart';
import '../utils/constants.dart';
import '../widgets/joined_event_previewer.dart';
import '/src/widgets/events_previewer.dart';
import '/src/widgets/widgets.dart';

import '/src/widgets/calendar.dart';
import '/src/widgets/date_selector.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

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
                    events: appState.selectedEvents,
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final appState = Provider.of<ApplicationState>(context, listen: false);
      appState.selectedEvent = null;
      appState.selectedDay = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) =>
        Scaffold(
          appBar: const AppBarCustom(),
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.white
            ),
            child: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(child: DateSelector(selectedDay: appState.selectedDay, toggleCalendar: toggleCalendar)),
                      const SizedBox(height: 15),
                      const Divider(height: 5, thickness: 3, color: kWYAOrange,),
                      const SizedBox(height: 20),
                      Expanded(flex: 5, child: EventsPreviewer(events: appState.selectedEvents, setSelectedEvent: (event) => appState.selectedEvent = event,)),
                      const SizedBox(height: 20),
                      const Divider(height: 5, thickness: 3, color: kWYAOrange,),
                      const SizedBox(height: 20),
                      Expanded(flex: 3, child: JoinedEventPreviewer(joinedEvents: appState.selectedJoinedEvents, setSelectedSharedEvent: (sharedEvent) => appState.selectedSharedEvent = sharedEvent,
                        uid: appState.userData.uid,)),
                    ],
                  )),
            ),
          ),
          bottomNavigationBar: const BottomAppBarCustom(current: 'waves'),
        ),
    );
  }
}
