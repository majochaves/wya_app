import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/event_category.dart';
import 'package:wya_final/src/utils/constants.dart';
import 'package:wya_final/src/utils/string_formatter.dart';
import 'package:wya_final/src/widgets.dart';

import '../app_state.dart';
import '../event.dart';
import '../location.dart';

class MyEventPage extends StatefulWidget {
  final String eventId;
  const MyEventPage({Key? key, required this.eventId}) : super(key: key);

  @override
  State<MyEventPage> createState() => _MyEventPageState();
}

class _MyEventPageState extends State<MyEventPage> {

  Event event = Event.emptyEvent('', DateTime.now(), DateTime.now());
  Location location = Location.emptyLocation();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = Provider.of<ApplicationState>(context, listen: false);
      event = appState.getEventById(widget.eventId);
      location = await appState.getLocationById(event.locationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => Scaffold(
        appBar: AppBar(
          title: const Text('WYA'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: RoundedContainer(
              backgroundColor: Colors.white,
              padding: 15,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event: ${appState.getEventById(widget.eventId).description}',
                      style: kH2SourceSansTextStyle,),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Event type: ', style: kH4SourceSansTextStyle,),
                        Text(EventCategory.getCategoryById(appState.getEventById(widget.eventId).category).name),
                        Image(image: EventCategory.getCategoryById(appState.getEventById(widget.eventId).category).icon.image,
                        height: 30,),
                      ],
                    ),
                    Visibility(
                      visible: !appState.getEventById(widget.eventId).isOpen,
                      child: Row(
                        children: [
                          Text('Join requests: ', style: kH4SourceSansTextStyle,),
                          appState.getEventById(widget.eventId).requests.isEmpty ? Text('None yet') :
                              Text('(${appState.getEventById(widget.eventId).requests.length})'),
                          TextButton(child: Text('View requests'), onPressed: (){},),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text('Participants: ', style: kH4SourceSansTextStyle,),
                        appState.getEventById(widget.eventId).participants.isEmpty ? Text('None yet') :
                        Text('(${appState.getEventById(widget.eventId).participants.length})'),
                        TextButton(child: Text('View participants'), onPressed: (){},),
                      ],
                    ),
                    Divider(),
                    Text('Event information: ', ),
                    Row(
                      children: [
                        const Text('Date: ', style: kH4SourceSansTextStyle,),
                        Text(StringFormatter.getDayText(appState.getEventById(widget.eventId).startsAt))
                      ],
                    ),
                    Row(
                      children: [
                        Text('Time: ', style: kH4SourceSansTextStyle,),
                        Text('${StringFormatter.getTimeString(appState.getEventById(widget.eventId).startsAt)}'
                            '-${StringFormatter.getTimeString(appState.getEventById(widget.eventId).endsAt)}')
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Location: ', style: kH4SourceSansTextStyle,),
                        Text(location.formattedAddress!),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Open event: '),
                        event.isOpen ? Text('True') : Text('False')
                      ],
                    ),
                    Row(
                      children: [
                        Text('Shared with: '),
                        event.sharedWithAll ? Text('All friends>') : Text('False')
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const BottomAppBarCustom(current: 'account',),
      ),
    );
  }
}
