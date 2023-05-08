import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/app_state.dart';
import 'package:wya_final/src/events_previewer.dart';
import 'package:wya_final/src/widgets.dart';

import 'calendar.dart';
import 'date_selector.dart';

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
          appBar: AppBar(
            title: const Text('WYA'),
          ),
          body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(child: DateSelector(selectedDay: appState.selectedDay, toggleCalendar: toggleCalendar)),
                    Expanded(flex: 12, child: EventsPreviewer(events: appState.selectedEvents, setSelectedEvent: (event) => appState.selectedEvent = event,)),
                  ],
                )),
          ),
          bottomNavigationBar: const BottomAppBarCustom(current: 'account'),
        ),
    );
  }
}
