import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/models/event_category.dart';
import 'package:wya_final/utils/constants.dart';
import 'package:wya_final/utils/string_formatter.dart';
import '/widgets/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app_state.dart';
import '../models/event.dart';
import '../models/location.dart';
import '../models/user_data.dart';



class EventViewer extends StatefulWidget {
  const EventViewer({Key? key}) : super(key: key);

  @override
  State<EventViewer> createState() => _EventViewerState();
}

class _EventViewerState extends State<EventViewer> {

  var _kMapCenter;

  GoogleMapController? controller;

  bool isLoading = true;

  Event? event;
  Location? location;
  String description = '';
  String categoryName = '';
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
        _kMapCenter = LatLng(location!.latitude, location!.longitude);
        friends = appState.friends;
        description = event!.description;
        categoryName = EventCategory.getCategoryById(event!.category).name;
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
                                appState.acceptEventRequest(event!.eventId, user.uid);
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

  Marker _createMarker() {
    return Marker(
      markerId: const MarkerId('marker_1'),
      position: _kMapCenter,
    );
  }

  void onMapCreated(GoogleMapController controllerParam) {
    setState(() {
      controller = controllerParam;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => Scaffold(
        appBar: const AppBarCustom(),
        body: SafeArea(
          child: isLoading ? const Center(child: CircularProgressIndicator(color: kDeepBlue,),) : Padding(
            padding: const EdgeInsets.all(16),
            child: RoundedContainer(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            //border: Border.all(color: Colors.black),
                            image: DecorationImage(image: Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/gradient${appState.selectedEvent!.category}.png').image),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SvgPicture.asset('/Users/majochaves/StudioProjects/wya_app/assets/icons/category${appState.selectedEvent!.category}.svg',
                            color: Colors.black, width: 100,),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Category: ', style: kH4SourceSansTextStyle,),
                                Text(categoryName),
                              ],
                            ),
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
                          ],
                        ),

                      ],
                    ),
                    const Text('Location: ', style: kH3SourceSansTextStyle,),
                    const SizedBox(height: 10,),
                    Text(locationAddress),
                    const SizedBox(height: 10,),
                    Center(child: SizedBox(height: 200, width: 250, child:
                    GoogleMap(
                      onMapCreated: onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _kMapCenter,
                        zoom: 13.0,
                      ),
                      markers: <Marker>{_createMarker()},
                    ),)
                    ,),
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
