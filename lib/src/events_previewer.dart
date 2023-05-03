import 'package:flutter/material.dart';
import 'package:wya_final/src/utils/constants.dart';
import '../event.dart';
import 'widgets.dart';


class EventsPreviewer extends StatelessWidget {
  final List<Event> events;

  EventsPreviewer({Key? key, required this.events}) : super(key: key);

  final List<List<Color>> colorCombos = [[kPastelBlue, kDeepBlue], [kPastelOrangeYellow, kOrange], [kPastelGreen, kGreen],
    [kPastelPink, kHotPink], [kPastelPurple, kPurple]];

  List<Widget> getEventCards() {
    List<Widget> eventCards = [];
    int index = 0;
    for(Event event in events){
      if (index > colorCombos.length){
        index = 0;
      }
      EventCard eventCard = EventCard(
        startTime: event.startsAt,
        endTime: event.endsAt,
        cardColor: colorCombos[index][0],
        iconColor: colorCombos[index][1],
        eventTitle: 'Hang out',
        eventDescription: event.description,
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
            'Your Events:',
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
              child: events.isEmpty ? Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  const Text("You have no events on this day. ",
                    textAlign: TextAlign.center, style: kBodyTextStyle,),
                  TextButton(onPressed: (){}, child: const Text(
                      'Add one', style: kBodyTextStyle
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
