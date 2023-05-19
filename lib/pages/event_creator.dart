import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wya_final/utils/constants.dart';
import 'package:wya_final/widgets/widgets.dart';

import '../../app_state.dart';
import '../models/event_category.dart';
import '../models/group.dart';
import '../models/user_data.dart';
import '../utils/location_provider.dart';
import '../models/event.dart';

class EventCreator extends StatefulWidget {
  const EventCreator({
    Key? key,
  }) : super(key: key);

  @override
  State<EventCreator> createState() => _EventCreatorState();
}

class _EventCreatorState extends State<EventCreator> {
  final _eventFormKey = GlobalKey<FormState>(debugLabel: '_NewEventStateForm');

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _errorController = TextEditingController();

  late LocationProvider locationProvider;
  PickResult? locationResult;

  bool isLoading = true;

  Event event = Event.emptyEvent('', DateTime.now(), DateTime.now());

  List<UserData> friends = [];
  Map<Group, List<UserData>> groups = {};

  List<UserData> eventParticipants = [];

  List<UserData> sharedWith = [];
  Map<Group, List<UserData>> eventGroups = {};

  bool addMembers = false;

  DateTime eventDate = DateTime.now();

  DateTime startTime = DateTime.now();

  DateTime endTime = DateTime.now();

  void getData() async{
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = Provider.of<ApplicationState>(context, listen: false);
      setState(() {
        friends = appState.friends;
        groups = appState.groups;

        eventParticipants = List.from(appState.friends);
        eventParticipants
            .removeWhere((element) => !event.participants.contains(element.uid));

        print(appState.selectedDay);
        eventDate = appState.selectedDay;
        startTime = isSameDay(appState.selectedDay, DateTime.now()) ? DateTime.now() : DateTime(eventDate.year, eventDate.month, eventDate.day, 0, 0);
        endTime = DateTime(eventDate.year, eventDate.month, eventDate.day, 23, 59);

        event = Event.emptyEvent(
            appState.userData.uid, appState.selectedDay, appState.endDay);
        isLoading = false;
      });

      locationProvider = await appState.location;

      setState(() {

      });

    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  ///SELECTORS

  void selectEventCategory(int typeIndex, bool isSelected) {
    int selectedCategory = 0;
    setState(() {
      if (isSelected) {
        if (typeIndex == 0) {
          selectedCategory = 0;
        } else if (typeIndex == 1) {
          if (event.category == 0) {
            selectedCategory = 1;
          }
        } else {
          selectedCategory = typeIndex - 1;
        }

        event = Event(
            description: event.description,
            uid: event.uid,
            eventId: event.eventId,
            datePublished: event.datePublished,
            startsAt: event.startsAt,
            endsAt: event.endsAt,
            participants: event.participants,
            locationId: event.locationId,
            sharedWithAll: event.sharedWithAll,
            isOpen: event.isOpen,
            groups: event.groups,
            category: selectedCategory,
            sharedWith: event.sharedWith,
            requests: event.requests
        );
      }
    });
  }

  selectIsOpen(bool isOpen) {
    setState(() {
      event = Event(
          description: event.description,
          uid: event.uid,
          eventId: event.eventId,
          datePublished: event.datePublished,
          startsAt: event.startsAt,
          endsAt: event.endsAt,
          participants: event.participants,
          locationId: event.locationId,
          sharedWithAll: event.sharedWithAll,
          isOpen: isOpen,
          groups: event.groups,
          category: event.category,
          sharedWith: event.sharedWith,
          requests: event.requests,
      );
    });
  }

  selectAddMembers(bool selectedAddMembers) {
    setState(() {
      addMembers = selectedAddMembers;
    });
  }

  selectIsSharedWithAll(bool isSharedWithAll) {
    setState(() {
      event = Event(
          description: event.description,
          uid: event.uid,
          eventId: event.eventId,
          datePublished: event.datePublished,
          startsAt: event.startsAt,
          endsAt: event.endsAt,
          participants: event.participants,
          locationId: event.locationId,
          sharedWithAll: isSharedWithAll,
          isOpen: event.isOpen,
          groups: event.groups,
          category: event.category,
          sharedWith: event.sharedWith,
          requests: event.requests,
      );
    });
  }

  changeStartDate(DateTime newEventDate) {
    setState(() {
      eventDate = newEventDate;
      if(!isSameDay(eventDate, DateTime.now())){
        eventDate = DateTime(eventDate.year, eventDate.month, eventDate.day, 0, 0);
      }else{
        eventDate = DateTime.now();
      }
      startTime = eventDate;
      endTime = eventDate;
    });
  }

  changeStartTime(DateTime newStartTime) {
    setState(() {
      startTime = DateTime(eventDate.year, eventDate.month, eventDate.day, newStartTime.hour, newStartTime.minute);
      DateTime newEndTime = DateTime(eventDate.year, eventDate.month, eventDate.day, endTime.hour, endTime.minute);
      if(newEndTime.isBefore(startTime)){
        endTime = startTime;
      }else{
        endTime = newEndTime;
      }
    });
  }

  changeEndTime(DateTime newEndTime) {
    if (DateTime(eventDate.year, eventDate.month, eventDate.day, newEndTime.hour, newEndTime.minute).isAfter(startTime)) {
      setState(() {
        endTime = DateTime(eventDate.year, eventDate.month, eventDate.day, newEndTime.hour, newEndTime.minute);
      });
    }
  }

  ///WINDOWS
  Future<void> _showAddMembersWindow() async {
    List<UserData> friendsNotAdded = List.from(friends);
    friendsNotAdded
        .removeWhere((element) => event.participants.contains(element.uid));

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return friends.isEmpty
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
                          child: eventParticipants.isEmpty
                              ? const Center(
                                  child: Text(
                                      'Your event has no members yet. Add a friend.'),
                                )
                              : UserListTiles(
                                  users: eventParticipants,
                                  icon: Icons.close,
                                  onPressed: (user) {
                                    setState(() {
                                      event.participants.remove(user.uid);
                                      eventParticipants.remove(user);
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
                                      event.participants.add(user.uid);
                                      eventParticipants.add(user);
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
    Map<Group, List<UserData>> groupsNotAdded = Map.from(groups);
    groupsNotAdded
        .removeWhere((key, value) => event.groups.contains(key.groupId));
    List<UserData> friendsNotAdded = List.from(friends);
    friendsNotAdded
        .removeWhere((element) => event.sharedWith.contains(element.uid));

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return friends.isEmpty
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
                    height: 450,
                    width: 300,
                    child: Column(
                      children: [
                        Expanded(
                            flex: 4,
                            child:
                                Row(mainAxisSize: MainAxisSize.max, children: [
                              Visibility(
                                visible: groups.isNotEmpty,
                                child: Expanded(
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
                                        child: eventGroups.isEmpty
                                            ? const Center(
                                                child: Text(
                                                    "You haven't added any groups"))
                                            : GroupListTiles(
                                                groups: eventGroups,
                                                icon: Icons.close,
                                                onPressed: (MapEntry group) {
                                                  setState(() {
                                                    eventGroups.removeWhere(
                                                        (key, value) =>
                                                            key == group.key);
                                                    event.groups.remove(
                                                        group.key.groupId);
                                                    groupsNotAdded.putIfAbsent(
                                                        group.key,
                                                        () => group.value);
                                                  });
                                                }),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
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
                                      child: sharedWith.isEmpty
                                          ? const Center(
                                              child: Text(
                                                  "You haven't added any friends"))
                                          : UserListTiles(
                                              users: sharedWith,
                                              icon: Icons.close,
                                              onPressed: (UserData user) {
                                                setState(() {
                                                  sharedWith.remove(user);
                                                  event.sharedWith
                                                      .remove(user.uid);
                                                  friendsNotAdded.add(user);
                                                });
                                              }),
                                    )
                                  ],
                                ),
                              ),
                            ])),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                            visible: groups.isNotEmpty,
                            child: const Text('Your groups:',
                                style: kH4SourceSansTextStyle)),
                        Visibility(
                          visible: groups.isNotEmpty,
                          child: const SizedBox(
                            height: 10,
                          ),
                        ),
                        Visibility(
                          visible: groups.isNotEmpty,
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
                                      onPressed: (MapEntry group) {
                                        setState(() {
                                          eventGroups.putIfAbsent(
                                              group.key, () => group.value);
                                          for (UserData groupMember
                                              in group.value) {
                                            if (!sharedWith
                                                .contains(groupMember)) {
                                              sharedWith.add(groupMember);
                                              event.sharedWith
                                                  .add(groupMember.uid);
                                            }
                                          }
                                          groupsNotAdded.remove(group);
                                          friendsNotAdded.removeWhere(
                                              (element) => group.value
                                                  .contains(element));
                                        });
                                      })),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text('Your friends:',
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
                                        sharedWith.add(user);
                                        event.sharedWith.add(user.uid);
                                        friendsNotAdded.remove(user);
                                      });
                                    })),
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
                      if (event.sharedWith.isEmpty) {
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

  ///CHIP GENERATORS

  List<Widget> getEventCategoryChips() {
    List<Widget> eventChips = [
      EventCategoryChip(
          icon: null,
          categoryName: 'Hang Out',
          index: 0,
          isSelected: event.category == 0,
          selectEventCategoryCallback: selectEventCategory),
      EventCategoryChip(
          icon: null,
          categoryName: 'Other',
          index: 1,
          isSelected: event.category != 0,
          selectEventCategoryCallback: selectEventCategory),
    ];
    return eventChips;
  }

  List<Widget> getOtherEventCategoryChips() {
    List<Widget> eventChips = [];
    List<EventCategory> eventCategories = EventCategory.getEventCategories();
    for (int i = 1; i < eventCategories.length; i++) {
      EventCategoryChip chip = EventCategoryChip(
          icon: SvgPicture.asset('/Users/majochaves/StudioProjects/wya_app/assets/icons/category$i.svg'),
          categoryName: eventCategories[i].name,
          index: i + 1,
          isSelected: event.category == i,
          selectEventCategoryCallback: selectEventCategory);
      eventChips.add(chip);
    }
    return eventChips;
  }

  @override
  Widget build(BuildContext context) {
    var datePicker = DateChooser(
      minDate: DateTime.now(),
      maxDate: DateTime(
          DateTime.now().year, DateTime.now().month + 3, DateTime.now().day),
      initDate: eventDate,
      toggleChangeDate: changeStartDate,
    );

    var startTimePicker = TimeChooser(
      initDate: startTime,
      toggleChangeTime: changeStartTime,
      minDate: isSameDay(startTime, DateTime.now()) ? DateTime.now() : DateTime(startTime.year, startTime.month, startTime.day, 0, 0),
      maxDate: DateTime(startTime.year, startTime.month, startTime.day, 23, 59),
    );

    var endTimePicker = TimeChooser(
      initDate: endTime.isBefore(startTime) ? startTime : endTime,
      toggleChangeTime: changeEndTime,
      minDate: startTime,
      maxDate: DateTime(startTime.year, startTime.month, startTime.day, 23, 59),
    );

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
                      Form(
                        key: _eventFormKey,
                        child: Column(
                          children: [
                            ///Event category
                            ChipsField(
                                title: const Text(
                                  'Event category: ',
                                  style: kEventFieldTitleTextStyle,
                                ),
                                height: 55,
                                flex1: 2,
                                flex2: 5,
                                chips: getEventCategoryChips()),
                            SizedBox(
                              height: event.category != 0 ? 20 : 0,
                            ),
                            Visibility(
                              visible: event.category != 0,
                              child: SizedBox(
                                width: double.infinity,
                                height: 150,
                                child: Wrap(
                                  spacing: 10.0,
                                  alignment: WrapAlignment.spaceAround,
                                  children: getOtherEventCategoryChips(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            ///Event description
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
                                          boolValue: event.isOpen,
                                          onChanged: selectIsOpen)),
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
                                onTap: _showAddMembersWindow,
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
                                          boolValue: event.sharedWithAll,
                                          onChanged: selectIsSharedWithAll)),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: !event.sharedWithAll,
                              child: InkWell(
                                onTap: _showShareWithWindow,
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
                                if(locationResult == null){
                                  _errorController.text = 'Please select a location for your event';
                                }else if(event.sharedWithAll == false && sharedWith.isEmpty){
                                  _errorController.text = 'Event must be shared with at least one friend';
                                }else{
                                  event = Event(
                                      description: _descriptionController.text,
                                      uid: event.uid,
                                      eventId: event.eventId,
                                      datePublished: event.datePublished,
                                      startsAt: startTime,
                                      endsAt: endTime,
                                      participants: event.participants,
                                      locationId: event.locationId,
                                      sharedWithAll: event.sharedWithAll,
                                      isOpen: event.isOpen,
                                      groups: event.groups,
                                      category: event.category,
                                      sharedWith: event.sharedWith,
                                      requests: event.requests
                                  );
                                  if(_eventFormKey.currentState!.validate()){
                                    await appState.addEvent(event, locationResult!);
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
        bottomNavigationBar: const BottomAppBarCustom(current: 'account'),
      ),
    );
  }
}
