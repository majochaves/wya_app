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

class SharedEventScreen extends StatefulWidget {
  const SharedEventScreen({Key? key}) : super(key: key);

  @override
  State<SharedEventScreen> createState() => _SharedEventScreenState();
}

class _SharedEventScreenState extends State<SharedEventScreen> {

  void getData() async{
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.getLocation(eventProvider.selectedSharedEvent!.event);
    _kMapCenter = LatLng(
        eventProvider.location!.latitude, eventProvider.location!.longitude);
    isLoading = false;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  var _kMapCenter;

  GoogleMapController? controller;

  bool isLoadingRequesting = false;
  bool isLoadingJoining = false;
  bool isLoading = true;


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
    return Scaffold(
        appBar: const AppBarCustom(),
        body: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: kDeepBlue,
          ),
        )
            : SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: RoundedContainer(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              padding: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('Event: ${eventProvider.description}',
                      style: kH2SourceSansTextStyle,),
                  ),
                  const SizedBox(width: 20,),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              //border: Border.all(color: Colors.black),
                              image: DecorationImage(image: Image.asset('assets/images/gradient${eventProvider.selectedSharedEvent!.event.category}.png').image),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SvgPicture.asset('assets/icons/category${eventProvider.selectedSharedEvent!.event.category}.svg',
                                color: Colors.black, width: 100,),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Text('Category: ', style: kH4SourceSansTextStyle,),
                                    Text(EventCategory.getCategoryById(eventProvider.category!).name),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    const Text('Date: ', style: kH4SourceSansTextStyle,),
                                    Text(StringFormatter.getDayText(eventProvider.startsAt!))
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    const Text('Time: ', style: kH4SourceSansTextStyle,),
                                    Text('${StringFormatter.getTimeString(eventProvider.startsAt!)}'
                                        '-${StringFormatter.getTimeString(eventProvider.endsAt!)}')
                                  ],
                                ),
                              ),
                      ]),
                        ),
                    ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Expanded(child: Text('Location: ', style: kH3SourceSansTextStyle,)),
                  const SizedBox(height: 10,),
                  Expanded(child: Text(eventProvider.location!.formattedAddress!)),
                  const SizedBox(height: 10,),
                  Expanded(
                    flex: 7,
                    child: Center(child: SizedBox(height: 200, width: 250, child:
                    GoogleMap(
                      onMapCreated: onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _kMapCenter,
                        zoom: 13.0,
                      ),
                      markers: <Marker>{_createMarker()},
                    ),)
                      ,),
                  ),
                  const SizedBox(height: 30,),
                  Expanded(
                    flex: 3,
                    child: Visibility(
                      visible: !eventProvider.isOpen!,
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
                  ),
                  Expanded(
                    flex: 3,
                    child: Visibility(
                      visible: eventProvider.isOpen!,
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
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomAppBar(current: 'account',),
    );
  }
}
