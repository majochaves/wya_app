import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wya_final/src/utils/constants.dart';
import '../shared_event.dart';
import 'widgets.dart';


class SharedEventPreviewer extends StatelessWidget {
  final List<SharedEvent> sharedEvents;

  SharedEventPreviewer({Key? key, required this.sharedEvents}) : super(key: key);

  final List<List<Color>> colorCombos = [[kPastelBlue, kDeepBlue], [kPastelOrangeYellow, kOrange], [kPastelGreen, kGreen],
    [kPastelPink, kHotPink], [kPastelPurple, kPurple]];

  List<Widget> getEventCards() {
    List<Widget> eventCards = [];
    int index = 0;
    for(SharedEvent sharedEvent in sharedEvents){
      if (index > colorCombos.length){
        index = 0;
      }
      SharedEventCard eventCard = SharedEventCard(
        userName: sharedEvent.user.name,
        userPicture: NetworkImage(sharedEvent.user.photoUrl,),
        time: sharedEvent.event.startsAt,
        cardColor: colorCombos[index][0],
        iconColor: colorCombos[index][1],
        eventTitle: 'Hang out',
        eventDescription: sharedEvent.event.description,
      );
      eventCards.add(eventCard);
      index++;
    }

    return eventCards;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          flex: 1,
          child: Text(
            'Shared Events:',
            style: kSubtitleTextStyle,
          ),
        ),
        Expanded(
          flex: 10,
          child: RoundedContainer(
            backgroundColor: kPastelGreen,
            padding: 20,
            child: SizedBox(
              width: double.infinity,
              child: sharedEvents.isEmpty ? Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  const Text("There are no shared events for this day. \n Find your friends: ",
                    textAlign: TextAlign.center, style: kBodyTextStyle,),
                  TextButton(onPressed: (){context.go('/search');}, child: const Text(
                      'Find friends', style: kBodyTextStyle
                  ))
                ],
              ) : ListView(
                scrollDirection: Axis.vertical,
                children: getEventCards(),
              ),
            ),

          ),
        ),
      ],
    );
  }
}
