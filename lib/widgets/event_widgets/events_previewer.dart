import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wya_final/utils/constants.dart';
import '../../models/event.dart';
import 'package:wya_final/widgets/widgets.dart';
import 'package:wya_final/widgets/event_widgets/event_card.dart';



class EventsPreviewer extends StatelessWidget {
  final Function setSelectedEvent;
  final List<Event> events;

  const EventsPreviewer({Key? key, required this.events, required this.setSelectedEvent}) : super(key: key);

  List<Widget> getEventCards() {
    List<Widget> eventCards = [];
    for(Event event in events){
      EventCard eventCard = EventCard(
        setSelectedEvent: setSelectedEvent,
        event: event,
      );
      eventCards.add(eventCard);
    }

    return eventCards;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: Text(
              'Your events:',
              style: kH3RubikTextStyle,
            ),
          ),
        ),
        Expanded(
          flex: 10,
          child: RoundedContainer(
            backgroundColor: Colors.white,
            padding: 0,
            child: SizedBox(
              width: double.infinity,
              child: events.isEmpty ? Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  Text("You have no events on this day. ",
                    textAlign: TextAlign.center, style: kBodyTextStyle,),
                  TextButton(onPressed: (){context.go('/newEvent');}, child: Text(
                      'Add one', style: kBodyTextStyle
                  ))
                ],
              ) : Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: getEventCards(),
                ),
              ),
            ),

          ),
        ),
      ],
    );
  }
}
