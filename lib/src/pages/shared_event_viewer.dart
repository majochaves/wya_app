import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/main.dart';
import 'package:wya_final/src/models/event_category.dart';
import 'package:wya_final/src/utils/constants.dart';
import 'package:wya_final/src/utils/string_formatter.dart';
import '/src/widgets/widgets.dart';

import '../../app_state.dart';
import '../models/event.dart';
import '../models/location.dart';
import '../models/shared_event.dart';
class SharedEventViewer extends StatefulWidget {
  const SharedEventViewer({Key? key}) : super(key: key);

  @override
  State<SharedEventViewer> createState() => _SharedEventViewerState();
}

class _SharedEventViewerState extends State<SharedEventViewer> {

  var _kMapCenter;

  GoogleMapController? controller;

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

  bool isLoadingRequesting = false;
  bool isLoadingJoining = false;

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
        _kMapCenter = LatLng(location!.latitude, location!.longitude);
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
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            //border: Border.all(color: Colors.black),
                            image: DecorationImage(image: Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/gradient${appState.selectedSharedEvent!.event.category}.png').image),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SvgPicture.asset('/Users/majochaves/StudioProjects/wya_app/assets/icons/category${appState.selectedSharedEvent!.event.category}.svg',
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
                      ]),
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
                    const SizedBox(height: 30,),
                    Visibility(
                      visible: !isOpen,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          !appState.selectedSharedEvent!.event.requests.contains(appState.userData.uid) ?
                          appState.selectedSharedEvent!.event.participants.contains(appState.userData.uid) ?
                              const Text('Joined') : SizedBox(
                            width: 300,
                            height: 50,
                                child: SpecialWYAButton(textColor: Colors.white, color: kWYAOrange, isLoading: isLoadingJoining, text: 'Request to join', onTap: () async {
                                  setState(() {
                                    isLoadingJoining = true;
                                  });
                                  await appState.requestToJoinEvent(appState.selectedSharedEvent!.event.eventId);
                                  setState(() {
                                    isLoadingJoining = false;
                                  });
                                }),
                              ) :
                          const Text('Requested'),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: isOpen,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          !appState.selectedSharedEvent!.event.participants.contains(appState.userData.uid) ?
                          SizedBox(
                            width: 300,
                            height: 50,
                            child: SpecialWYAButton(textColor: Colors.white, color: kWYAOrange, isLoading: isLoadingJoining, text: 'Join event', onTap: () async {
                              setState(() {
                                isLoadingRequesting = true;
                              });
                              await appState.joinEvent(appState.selectedSharedEvent!.event.eventId);
                              setState(() {
                                isLoadingRequesting = false;
                              });
                            }),
                          ) :
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
