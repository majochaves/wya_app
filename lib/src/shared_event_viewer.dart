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
import '../shared_event.dart';

class SharedEventViewer extends StatefulWidget {
  const SharedEventViewer({Key? key}) : super(key: key);

  @override
  State<SharedEventViewer> createState() => _SharedEventViewerState();
}

class _SharedEventViewerState extends State<SharedEventViewer> {

  bool isLoading = true;

  SharedEvent? event;
  Location? location;
  String description = '';
  String categoryName = '';
  Image categoryImage = Image.asset('assets/icons/nightlife.png');
  DateTime startsAt = DateTime.now();
  DateTime endsAt = DateTime.now();
  bool isOpen = true;
  int participants = 0;
  bool isPublic = true;
  String locationAddress = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async{
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = Provider.of<ApplicationState>(context, listen: false);
      event = appState.selectedSharedEvent;
      location = await appState.getLocationById(event!.event.locationId);
      setState(() {
        description = event!.event.description;
        categoryName = EventCategory.getCategoryById(event!.event.category).name;
        categoryImage = EventCategory.getCategoryById(event!.event.category).icon;
        startsAt = event!.event.startsAt;
        endsAt = event!.event.endsAt;
        isOpen = event!.event.isOpen;
        participants = event!.event.participants.length;
        isPublic = event!.event.sharedWithAll;
        locationAddress = location!.formattedAddress!;

        isLoading = false;
      });
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
                    Visibility(
                      visible: !isOpen,
                      child: Row(
                        children: [
                          !appState.selectedSharedEvent!.event.requests.contains(appState.userData.uid) ?
                          TextButton(child: const Text('Request to join'), onPressed: (){
                            appState.requestToJoinEvent(appState.selectedSharedEvent!.event.eventId, appState.userData.uid);
                          },) :
                          const Text('Requested'),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: isOpen,
                      child: Row(
                        children: [
                          !appState.selectedSharedEvent!.event.participants.contains(appState.userData.uid) ?
                          TextButton(child: const Text('Join event'), onPressed: (){
                            appState.joinEvent(appState.selectedSharedEvent!.event.eventId, appState.userData.uid);
                          },) :
                          const Text('Joined'),
                        ],
                      ),
                    ),
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
