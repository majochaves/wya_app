import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wya_final/providers/user_provider.dart';
import 'package:wya_final/utils/constants.dart';
import 'package:wya_final/widgets/widgets.dart';

import '../models/event_category.dart';
import '../models/group.dart';
import '../models/user_data.dart';
import '../providers/event_provider.dart';
import '../providers/group_provider.dart';
import '../utils/location_provider.dart';

class EventEditingScreen extends StatefulWidget {
  const EventEditingScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<EventEditingScreen> createState() => _EventEditingScreenState();
}

class _EventEditingScreenState extends State<EventEditingScreen> {

  final _eventFormKey = GlobalKey<FormState>(debugLabel: '_NewEventStateForm');

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _errorController = TextEditingController();

  LocationProvider locationProvider = LocationProvider();
  PickResult? locationResult;

  bool isLoading = true;
  bool addMembers = false;

  late DateTime eventDate;
  late DateTime startTime;
  late DateTime endTime;

  void getData() async{
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      setState(() {
        print('selectedDay: ${eventProvider.selectedDay}');
        print('startTime: ${eventProvider.startsAt}');
        print('endTime: ${eventProvider.endsAt}');
        eventDate = eventProvider.selectedDay;
        startTime = eventProvider.startsAt!;
        endTime = eventProvider.endsAt!;
        _descriptionController.text = eventProvider.description!;
        _locationController.text = eventProvider.location == null ? '' : eventProvider.location!.formattedAddress!;
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    locationProvider.getCurrentLocation();
    getData();
  }

  selectAddMembers(bool selectedAddMembers) {
    setState(() {
      addMembers = selectedAddMembers;
    });
  }

  changeStartDate(DateTime newEventDate) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    setState(() {
      eventDate = newEventDate;
      if(!isSameDay(eventDate, DateTime.now())){
        eventDate = DateTime(eventDate.year, eventDate.month, eventDate.day, 0, 0);
      }else{
        eventDate = DateTime.now();
      }
      startTime = eventDate;
      endTime = eventDate;
      eventProvider.startsAt = startTime;
      eventProvider.endsAt = endTime;

    });
  }

  changeStartTime(DateTime newStartTime) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    setState(() {
      startTime = DateTime(eventDate.year, eventDate.month, eventDate.day, newStartTime.hour, newStartTime.minute);
      DateTime newEndTime = DateTime(eventDate.year, eventDate.month, eventDate.day, endTime.hour, endTime.minute);
      if(newEndTime.isBefore(startTime)){
        endTime = startTime;
      }else{
        endTime = newEndTime;
      }
    });
    eventProvider.startsAt = startTime;
    eventProvider.endsAt = endTime;
  }

  changeEndTime(DateTime newEndTime) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    if (DateTime(eventDate.year, eventDate.month, eventDate.day, newEndTime.hour, newEndTime.minute).isAfter(startTime)) {
      setState(() {
        endTime = DateTime(eventDate.year, eventDate.month, eventDate.day, newEndTime.hour, newEndTime.minute);
      });
      eventProvider.endsAt = endTime;
    }
  }

  ///WINDOWS
  Future<void> _showAddMembersWindow() async {
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    List<UserData> friendsNotAdded = List.from(userProvider.friendInfo);
    friendsNotAdded
        .removeWhere((element) => eventProvider.participants.contains(element));

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return userProvider.friendInfo.isEmpty
            ? AlertDialog(
                content: const SizedBox(
                  height: 100,
                  width: 300,
                  child: Center(
                    child: Text(
                        'You have no friends. Add friends first to add members to your event.'),
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
                title: const Text('Group members: '),
                content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    height: 350,
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text(
                          'Members: ',
                          style: kH4SourceSansTextStyle,
                        ),
                        Expanded(
                          flex: 4,
                          child: eventProvider.participants.isEmpty
                              ? const Center(
                                  child: Text(
                                      'Your event has no members yet. Add a friend.'),
                                )
                              : UserListTiles(
                                  users: eventProvider.participants,
                                  icon: Icons.close,
                                  onPressed: (user) {
                                    setState(() {
                                      eventProvider.removeParticipant(user);
                                      friendsNotAdded.add(user);
                                    });
                                  }),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Add Friends:',
                            style: kH4SourceSansTextStyle),
                        Expanded(
                          flex: 4,
                          child: friendsNotAdded.isEmpty
                              ? const Center(
                                  child: Text(
                                      "You've added all your friends to this event."),
                                )
                              : UserListTiles(
                                  users: friendsNotAdded,
                                  icon: Icons.add,
                                  onPressed: (user) {
                                    setState(() {
                                      eventProvider.addParticipant(user);
                                      friendsNotAdded.remove(user);
                                    });
                                  }),
                        ),
                      ],
                    ),
                  );
                }),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
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

  Future<void> _showShareWithWindow() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    List<Group> groupsNotAdded = List.from(groupProvider.groups);
    groupsNotAdded
        .removeWhere((element) => eventProvider.groups.contains(element));

    List<UserData> friendsNotAdded = List.from(userProvider.friendInfo);
    friendsNotAdded
        .removeWhere((element) => eventProvider.sharedWith.contains(element));
    print('groups is empty: ${groupProvider.groups.isEmpty.toString()}');

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return userProvider.friendInfo.isEmpty
            ? AlertDialog(
                content: const SizedBox(
                  height: 100,
                  width: 300,
                  child: Center(
                    child: Text(
                        'You have no friends. Add friends first to share your event.'),
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
                title: const Text('Share with: '),
                content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    height: 400,
                    width: 450,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Visibility(
                            visible: groupProvider.groups.isNotEmpty,
                            child: SizedBox(
                              height: eventProvider.groups.isEmpty ? 100 : 200,
                              width:  450,
                              child: Column(
                                children: [
                                  const Expanded(
                                      child: Text(
                                    'Groups shared with: ',
                                    style: kH4SourceSansTextStyle,
                                    textAlign: TextAlign.center,
                                  )),
                                  Expanded(
                                    flex: 5,
                                    child: eventProvider.groups.isEmpty
                                        ? const Center(
                                            child: Text(
                                                "You haven't added any groups"))
                                        : GroupListTiles(
                                            groups: eventProvider.groups,
                                            icon: Icons.close,
                                            onPressed: (Group group) {
                                              setState(() {
                                                eventProvider.removeGroup(group);
                                                eventProvider.removeUsersFromSharedWith(groupProvider.getFriendsContainedIn(group.members));
                                              });
                                            }),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: eventProvider.sharedWith.isEmpty ? 100 : 200,
                            width:450,
                            child: Column(
                              children: [
                                const Expanded(
                                    child: Text(
                                  'Friends shared with: ',
                                  style: kH4SourceSansTextStyle,
                                  textAlign: TextAlign.center,
                                )),
                                Expanded(
                                  flex: 5,
                                  child: eventProvider.sharedWith.isEmpty
                                      ? const Center(
                                          child: Text(
                                              "You haven't added any friends"))
                                      : UserListTiles(
                                          users: eventProvider.sharedWith,
                                          icon: Icons.close,
                                          onPressed: (UserData user) {
                                            setState(() {
                                              eventProvider.removeUserFromSharedWith(user);
                                              friendsNotAdded.add(user);
                                            });
                                          }),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height:200,
                            width:450,
                            child: Column(children: [
                              Visibility(
                                  visible: groupProvider.groups.isNotEmpty,
                                  child: const Text('Your groups:',
                                      style: kH4SourceSansTextStyle)),
                              Visibility(
                                visible: groupProvider.groups.isNotEmpty,
                                child: const SizedBox(
                                  height: 10,
                                ),
                              ),
                              Visibility(
                                visible: groupProvider.groups.isNotEmpty,
                                child: Expanded(
                                    flex: 2,
                                    child: groupsNotAdded.isEmpty
                                        ? const Center(
                                      child: Text(
                                          "You've added all your groups to this event."),
                                    )
                                        : GroupListTiles(
                                        groups: groupsNotAdded,
                                        icon: Icons.add,
                                        onPressed: (Group group) {
                                          setState(() {
                                            List<UserData> groupMembers = groupProvider.getFriendsContainedIn(group.members);
                                            eventProvider.addGroup(group);
                                            for (UserData groupMember
                                            in groupMembers) {
                                              if (!eventProvider.sharedWith
                                                  .contains(groupMember)) {
                                                eventProvider.addUserToSharedWith(groupMember);
                                              }
                                            }
                                            groupsNotAdded.remove(group);
                                            friendsNotAdded.removeWhere(
                                                    (element) => groupMembers
                                                    .contains(element));
                                          });
                                        })),
                              ),
                            ],),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(height:200, width:450, child: Column(children: [const Text('Your friends:',
                              style: kH4SourceSansTextStyle),
                            const SizedBox(
                              height: 10,
                            ),
                            Expanded(
                                flex: 2,
                                child: friendsNotAdded.isEmpty
                                    ? const Center(
                                  child: Text(
                                      "You've added all your friends to this event."),
                                )
                                    : UserListTiles(
                                    users: friendsNotAdded,
                                    icon: Icons.add,
                                    onPressed: (user) {
                                      setState(() {
                                        eventProvider.addUserToSharedWith(user);
                                        friendsNotAdded.remove(user);
                                      });
                                    })),],)),

                          SizedBox(
                            height: 20,
                            width: 300,
                            child: TextField(
                              style: TextStyle(color: Colors.red.shade700),
                              controller: _errorController,
                              readOnly: true,
                              enabled: false,
                              decoration: const InputDecoration(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      _errorController.clear();
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Done'),
                    onPressed: () {
                      if (eventProvider.sharedWith.isEmpty) {
                        setState(() {
                          _errorController.text =
                              'Group must be shared with at least one friend.';
                        });
                      }
                      _errorController.clear();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
      },
    );
  }

  Future<void> _showLocationWindow() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('Select location'),
            content: SizedBox(
                height: 550,
                width: 300,
                child: Column(
                  children: [
                    Expanded(
                      child: PlacePicker(
                        apiKey: "AIzaSyAJ1RJYFrFN2uoBZc8nL2-nQPqOBGp-IvU",
                        onPlacePicked: (result) {
                          setState(() {
                            locationResult = result;
                            _locationController.text =
                                result.formattedAddress.toString();
                            eventProvider.setLocation(
                                result.formattedAddress!,
                                result.url ?? '',
                                result.geometry!.location.lat,
                                result.geometry!.location.lng
                            );
                          });
                        },
                        initialPosition: locationResult == null
                            ? LatLng(locationProvider.latitude,
                                locationProvider.longitude)
                            : LatLng(locationResult!.geometry!.location.lat,
                                locationResult!.geometry!.location.lng),
                        useCurrentLocation: true,
                        resizeToAvoidBottomInset: false,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text('Selected location: '),
                    TextFormField(
                      readOnly: true,
                      enabled: false,
                      controller: _locationController,
                    ),
                  ],
                )),
            actions: <Widget>[
              TextButton(
                child: const Text('Done'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final eventProvider = Provider.of<EventProvider>(context);

    List<Widget> eventChips = [];
    List<EventCategory> eventCategories = EventCategory.getEventCategories();
    for (int i = 0; i < eventCategories.length; i++) {
      EventCategoryChip chip = EventCategoryChip(
          icon: SvgPicture.asset('assets/icons/category$i.svg'),
          categoryName: eventCategories[i].name,
          index: i,
          isSelected: eventProvider.category == i,
          selectEventCategoryCallback: (int index, bool isSelected) {
            if(isSelected){
              eventProvider.category = index;
            }
          });
      eventChips.add(chip);
    }

    var datePicker = DateChooser(
      minDate: DateTime.now(),
      maxDate: DateTime(
          DateTime.now().year, DateTime.now().month + 3, DateTime.now().day),
      initDate: eventProvider.startsAt!,
      toggleChangeDate: changeStartDate,
    );

    var startTimePicker = TimeChooser(
      initDate: eventProvider.startsAt!,
      toggleChangeTime: changeStartTime,
      minDate: isSameDay(eventProvider.startsAt, DateTime.now()) ? DateTime.now() : DateTime(eventProvider.startsAt!.year, eventProvider.startsAt!.month, eventProvider.startsAt!.day, 0, 0),
      maxDate: DateTime(eventProvider.startsAt!.year, eventProvider.startsAt!.month, eventProvider.startsAt!.day, 23, 59),
    );

    var endTimePicker = TimeChooser(
      initDate: eventProvider.endsAt!.isBefore(eventProvider.startsAt!) ? eventProvider.startsAt! : eventProvider.endsAt!,
      toggleChangeTime: changeEndTime,
      minDate: eventProvider.startsAt!,
      maxDate: DateTime(eventProvider.startsAt!.year, eventProvider.startsAt!.month, eventProvider.startsAt!.day, 23, 59),
    );

    return Scaffold(
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
                      Form(
                        key: _eventFormKey,
                        child: Column(
                          children: [
                            const Text(
                              'Event category: ',
                              style: kEventFieldTitleTextStyle,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 150,
                              child: Wrap(
                                spacing: 10.0,
                                alignment: WrapAlignment.spaceAround,
                                children: eventChips,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Description: ',
                                    style: kEventFieldTitleTextStyle,
                                  ),
                                  TextFormField(
                                    controller: _descriptionController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter event description',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Enter your event's description-";
                                      }
                                      return null;
                                    },
                                    onChanged: (value) => eventProvider.description = value,
                                  ),
                                ],
                              ),
                            ),

                            ///Event location
                            SizedBox(
                              height: 100,
                              child: InkWell(
                                onTap: () {
                                  _showLocationWindow();
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Location: ',
                                      style: kEventFieldTitleTextStyle,
                                    ),
                                    TextFormField(
                                      enabled: false,
                                      readOnly: true,
                                      controller: _locationController,
                                      decoration: const InputDecoration(
                                        icon: Icon(Icons.location_on),
                                        iconColor: kDeepBlue,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter your event's location";
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            ///Event date and time
                            SizedBox(
                              height: 60,
                              child: Row(
                                children: <Widget>[
                                  const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'Date: ',
                                        style: kEventFieldTitleTextStyle,
                                      )),
                                  Expanded(flex: 3, child: datePicker),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 70,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  const Expanded(
                                      child: Text(
                                    'Start: ',
                                    style: kEventFieldTitleTextStyle,
                                  )),
                                  Expanded(child: startTimePicker),
                                  const Expanded(
                                      child: Text(
                                    'End: ',
                                    style: kEventFieldTitleTextStyle,
                                  )),
                                  Expanded(child: endTimePicker),
                                ],
                              ),
                            ),

                            ///MEMBERS AND PRIVACY SETTINGS
                            SizedBox(
                              height: 100,
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 5,
                                    child: TitleDescriptionColumn(
                                        title: 'Open event: ',
                                        description:
                                            'Your friends can join automatically'),
                                  ),
                                  Expanded(
                                      child: OptionSwitch(
                                          boolValue: eventProvider.isOpen!,
                                          onChanged: (bool value) {
                                            eventProvider.isOpen = value;
                                          })),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 100,
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 5,
                                    child: TitleDescriptionColumn(
                                        title: 'Add members: ',
                                        description:
                                            'Add friends who you know are coming \nto your event.'),
                                  ),
                                  Expanded(
                                      child: OptionSwitch(
                                          boolValue: addMembers,
                                          onChanged: selectAddMembers)),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: addMembers,
                              child: InkWell(
                                onTap: () {_showAddMembersWindow();},
                                child: const RoundedContainer(
                                  backgroundColor: kPastelBlue,
                                  padding: 10,
                                  child: Center(
                                      child: Text(
                                    'Select members',
                                    style: kH3SourceSansTextStyle,
                                  )),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 100,
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 5,
                                    child: TitleDescriptionColumn(
                                        title: 'Public event: ',
                                        description:
                                            'Share with all your friends'),
                                  ),
                                  Expanded(
                                      child: OptionSwitch(
                                          boolValue: eventProvider.sharedWithAll!,
                                          onChanged: (bool value){
                                        eventProvider.sharedWithAll = value;
                                  }),
                                  ),],
                              ),
                            ),
                            Visibility(
                              visible: !eventProvider.sharedWithAll!,
                              child: InkWell(
                                onTap: () {_showShareWithWindow();},
                                child: const RoundedContainer(
                                  backgroundColor: kPastelBlue,
                                  padding: 10,
                                  child: Center(
                                      child: Text(
                                    'Share with: ',
                                    style: kH3SourceSansTextStyle,
                                  )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: _errorController.text.isNotEmpty,
                        child: SizedBox(
                          height: 20,
                          width: 300,
                          child: TextField(
                            style: TextStyle(color: Colors.red.shade700),
                            controller: _errorController,
                            readOnly: true,
                            enabled: false,
                            decoration: const InputDecoration(),
                          ),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        kDeepBlue),
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.all(10)),
                              ),
                              child: const Text('Save'),
                              onPressed: () async {
                                if(eventProvider.location == null){
                                  _errorController.text = 'Please select a location for your event';
                                }else if(eventProvider.sharedWithAll == false && eventProvider.sharedWith.isEmpty){
                                  _errorController.text = 'Event must be shared with at least one friend';
                                }else{
                                  if(_eventFormKey.currentState!.validate()){
                                    eventProvider.saveEvent();
                                    context.go('/events');
                                  }
                                }
                              },
                            )
                          ])
                    ],
                  ),
                ),
              )),
        ),
        bottomNavigationBar: const CustomBottomAppBar(current: 'account'),
    );
  }
}
