import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/providers/event_provider.dart';
import 'package:wya_final/providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/joined_event_previewer.dart';
import '/widgets/events_previewer.dart';
import '/widgets/widgets.dart';

import '/widgets/calendar.dart';
import '/widgets/date_selector.dart';

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
          content: Consumer<EventProvider>(builder: (context, eventProvider, _) =>
              SizedBox(height:350, width: 300,
                child: Calendar(
                    events: eventProvider.eventsForDay(eventProvider.selectedDay),
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider.selectedEvent = null;
      eventProvider.selectedDay = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Consumer<EventProvider>(builder: (context, eventProvider, _) =>
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
                      Expanded(child: DateSelector(selectedDay: eventProvider.selectedDay, toggleCalendar: toggleCalendar)),
                      const SizedBox(height: 15),
                      const Divider(height: 5, thickness: 3, color: kWYAOrange,),
                      const SizedBox(height: 20),
                      Expanded(flex: 5, child: EventsPreviewer(events: eventProvider.eventsForDay(eventProvider.selectedDay), setSelectedEvent: (event) => eventProvider.setSelectedEvent(event),)),
                      const SizedBox(height: 20),
                      const Divider(height: 5, thickness: 3, color: kWYAOrange,),
                      const SizedBox(height: 20),
                      Expanded(flex: 3, child: JoinedEventPreviewer(joinedEvents: eventProvider.joinedEventsForDay(eventProvider.selectedDay), setSelectedSharedEvent: (sharedEvent) => eventProvider.setSelectedSharedEvent(sharedEvent),
                        uid: userProvider.uid!,)),
                    ],
                  )),
            ),
          ),
          bottomNavigationBar: const BottomAppBarCustom(current: 'waves'),
        ),
    );
  }
}
