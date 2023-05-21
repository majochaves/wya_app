import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/models/event_category.dart';
import 'package:wya_final/providers/event_provider.dart';
import 'package:wya_final/providers/user_provider.dart';
import 'package:wya_final/utils/constants.dart';
import 'package:wya_final/utils/string_formatter.dart';
import '/widgets/widgets.dart';

class SharedEventViewer extends StatefulWidget {
  const SharedEventViewer({Key? key}) : super(key: key);

  @override
  State<SharedEventViewer> createState() => _SharedEventViewerState();
}

class _SharedEventViewerState extends State<SharedEventViewer> {

  var _kMapCenter;

  GoogleMapController? controller;

  bool isLoadingRequesting = false;
  bool isLoadingJoining = false;

  @override
  void initState() {
    super.initState();
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
    final userProvider = Provider.of<UserProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    _kMapCenter = LatLng(eventProvider.location!.latitude, eventProvider.location!.longitude);
    return Scaffold(
        appBar: const AppBarCustom(),
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
                    Text('Event: ${eventProvider.description}',
                      style: kH2SourceSansTextStyle,),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            //border: Border.all(color: Colors.black),
                            image: DecorationImage(image: Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/gradient${eventProvider.selectedSharedEvent!.event.category}.png').image),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SvgPicture.asset('/Users/majochaves/StudioProjects/wya_app/assets/icons/category${eventProvider.selectedSharedEvent!.event.category}.svg',
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
                                Text(EventCategory.getCategoryById(eventProvider.category).name),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('Date: ', style: kH4SourceSansTextStyle,),
                                Text(StringFormatter.getDayText(eventProvider.startsAt))
                              ],
                            ),
                            Row(
                              children: [
                                const Text('Time: ', style: kH4SourceSansTextStyle,),
                                Text('${StringFormatter.getTimeString(eventProvider.startsAt)}'
                                    '-${StringFormatter.getTimeString(eventProvider.endsAt)}')
                              ],
                            ),
                      ]),
                    ],
                    ),
                    const Text('Location: ', style: kH3SourceSansTextStyle,),
                    const SizedBox(height: 10,),
                    Text(eventProvider.location!.formattedAddress!),
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
                      visible: !eventProvider.isOpen,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          !eventProvider.selectedSharedEvent!.event.requests.contains(userProvider.uid!) ?
                          eventProvider.selectedSharedEvent!.event.participants.contains(userProvider.uid!) ?
                              const Text('Joined') : SizedBox(
                            width: 300,
                            height: 50,
                                child: SpecialWYAButton(textColor: Colors.white, color: kWYAOrange, isLoading: isLoadingJoining, text: 'Request to join', onTap: () async {
                                  setState(() {
                                    isLoadingJoining = true;
                                  });
                                  await eventProvider.requestToJoinEvent(eventProvider.selectedSharedEvent!.event.eventId);
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
                      visible: eventProvider.isOpen,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          !eventProvider.selectedSharedEvent!.event.participants.contains(userProvider.uid!) ?
                          SizedBox(
                            width: 300,
                            height: 50,
                            child: SpecialWYAButton(textColor: Colors.white, color: kWYAOrange, isLoading: isLoadingJoining, text: 'Join event', onTap: () async {
                              setState(() {
                                isLoadingRequesting = true;
                              });
                              await eventProvider.joinEvent(eventProvider.selectedSharedEvent!.event.eventId);
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
    );
  }
}
