import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/event_category.dart';
import 'package:wya_final/src/utils/constants.dart';
import 'package:wya_final/src/utils/string_formatter.dart';
import 'package:wya_final/src/widgets.dart';

import '../app_state.dart';
import '../event.dart';
import '../location.dart';
import '../user_data.dart';

class EventViewer extends StatefulWidget {
  const EventViewer({Key? key}) : super(key: key);

  @override
  State<EventViewer> createState() => _EventViewerState();
}

class _EventViewerState extends State<EventViewer> {

  bool isLoading = true;

  Event? event;
  Location? location;
  String description = '';
  String categoryName = '';
  Image categoryImage = Image.asset('assets/icons/nightlife.png');
  DateTime startsAt = DateTime.now();
  DateTime endsAt = DateTime.now();
  bool isOpen = true;
  int joinRequests = 0;
  int participants = 0;
  bool isPublic = true;
  String locationAddress = '';

  List<UserData> friends = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async{
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final appState = Provider.of<ApplicationState>(context, listen: false);
    event = appState.selectedEvent;
    location = await appState.getLocationById(event!.locationId);
    setState(() {
        friends = appState.friends;
        description = event!.description;
        categoryName = EventCategory.getCategoryById(event!.category).name;
        categoryImage = EventCategory.getCategoryById(event!.category).icon;
        startsAt = event!.startsAt;
        endsAt = event!.endsAt;
        isOpen = event!.isOpen;
        joinRequests = event!.requests.length;
        participants = event!.participants.length;
        isPublic = event!.sharedWithAll;
        locationAddress = location!.formattedAddress!;

        isLoading = false;
      });
    });
  }

  Future<void> _showRequestsWindow() async {
    List<UserData> requests = List.from(friends);
    requests.removeWhere((element) => !event!.requests.contains(element.uid));

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return requests.isEmpty
            ? AlertDialog(
          content: const SizedBox(
            height: 100,
            width: 300,
            child: Center(
              child: Text(
                  'You have no requests yet.'),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        )
            : AlertDialog(
          title: const Text('Requests: '),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Consumer<ApplicationState>(
                    builder: (context, appState, _) => SizedBox(
                  height: 350,
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text(
                        'Requests: ',
                        style: kH4SourceSansTextStyle,
                      ),
                      requests.isEmpty ? const Center(child: Text('You have no requests'),) : Expanded(
                        flex: 4,
                        child: UserListTiles(
                            users: requests,
                            icon: Icons.check,
                            onPressed: (user) {
                              setState(() {
                                appState.joinEvent(event!.eventId, user.uid);
                                event!.participants.add(user.uid);
                                event!.requests.remove(user.uid);
                                requests.remove(user);
                              });
                            }),
                      ),
                    ],
                  ),
                ),);
              }),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showParticipantsWindow() async {
    List<UserData> participants = List.from(friends);
    participants.removeWhere((element) => !event!.participants.contains(element.uid));

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Participants: '),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Consumer<ApplicationState>(
                  builder: (context, appState, _) => SizedBox(
                    height: 350,
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text(
                          'Participants: ',
                          style: kH4SourceSansTextStyle,
                        ),
                        appState.selectedEvent!.participants.isEmpty ? const Center(child: Text('Your event has no participants'),) : Expanded(
                          flex: 4,
                          child: UserListTiles(
                              users: participants,
                              icon: Icons.close,
                              onPressed: (user) {
                                setState(() {
                                  appState.removeParticipant(event!.eventId, user.uid);
                                  event!.participants.remove(user.uid);
                                  participants.remove(user);
                                });
                              }),
                        ),
                      ],
                    ),
                  ),);
              }),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
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
      builder: (context, appState, _) => Scaffold(
        appBar: AppBar(
          title: const Text('WYA'),
        ),
        body: SafeArea(
          child: isLoading ? const Center(child: CircularProgressIndicator(color: kDeepBlue,),) : Padding(
            padding: const EdgeInsets.all(16),
            child: RoundedContainer(
              backgroundColor: Colors.white,
              padding: 15,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event: $description',
                      style: kH2SourceSansTextStyle,),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Event type: ', style: kH4SourceSansTextStyle,),
                        Text(categoryName),
                        Image(image: categoryImage.image, height: 30,),
                      ],
                    ),
                    Visibility(
                      visible: !isOpen,
                      child: Row(
                        children: [
                          const Text('Join requests: ', style: kH4SourceSansTextStyle,),
                          appState.selectedEvent!.requests.isEmpty ?  const Text('None yet') :
                              Text('(${appState.selectedEvent!.requests.length})'),
                          TextButton(child: const Text('View requests'), onPressed: (){
                            _showRequestsWindow();
                          },),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Text('Participants: ', style: kH4SourceSansTextStyle,),
                        appState.selectedEvent!.participants.isEmpty ? const Text('None yet') :
                        Text('(${appState.selectedEvent!.participants.length})'),
                        TextButton(child: const Text('View participants'), onPressed: (){
                          _showParticipantsWindow();
                        },),
                      ],
                    ),
                    const Divider(),
                    const Text('Event information: ', style: kH3SourceSansTextStyle,),
                    Row(
                      children: [
                        const Text('Date: ', style: kH4SourceSansTextStyle,),
                        Text(StringFormatter.getDayText(startsAt))
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Time: ', style: kH4SourceSansTextStyle,),
                        Text('${StringFormatter.getTimeString(startsAt)}'
                            '-${StringFormatter.getTimeString(endsAt)}')
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Location: ', style: kH4SourceSansTextStyle,),
                        Expanded(child: Text(locationAddress)),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Open event: ', style: kH4SourceSansTextStyle,),
                        isOpen ? const Text('True') : const Text('False')
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Shared with: ', style: kH4SourceSansTextStyle,),
                        isPublic ? const Text('All friends') : TextButton(child: const Text('View shared with'), onPressed: () {},)
                      ],
                    ),
                    const SizedBox(height: 50,),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      TextButton(child: const Text('Edit event'), onPressed: () {
                        context.go('/editEvent');
                      },),
                      const SizedBox(width: 50,),
                      TextButton(child: const Text('Delete event'), onPressed: () {
                        appState.deleteEvent(event!.eventId);
                        context.go('/events');
                      },),
                    ],)
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
