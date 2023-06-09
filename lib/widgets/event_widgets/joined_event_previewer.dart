import 'package:flutter/material.dart';
import 'package:wya_final/utils/constants.dart';
import 'package:wya_final/widgets/event_widgets/joined_event_card.dart';

import '../../models/shared_event.dart';


class JoinedEventPreviewer extends StatelessWidget {
  final List<SharedEvent> joinedEvents;
  final Function setSelectedSharedEvent;
  final String uid;

  const JoinedEventPreviewer({Key? key, required this.joinedEvents, required this.uid, required this.setSelectedSharedEvent}) : super(key: key);


  List<Widget> getJoinedEventCards() {
    List<Widget> joinedEventCards = [];

    for(SharedEvent joinedEvent in joinedEvents){
      JoinedEventCard joinedEventCard = JoinedEventCard(
        setSelectedSharedEvent: setSelectedSharedEvent,
        event: joinedEvent,
        uid: uid,

      );
      joinedEventCards.add(joinedEventCard);
    }
    return joinedEventCards;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: Text(
              "Events you've joined: ",
              style: kH3RubikTextStyle,
              textAlign: TextAlign.start,
            ),
          ),
        ),
        const SizedBox(height: 10,),
        Expanded(
          flex: 6,
          child: SizedBox(
            width: double.infinity,
            child: joinedEvents.isEmpty ? Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Expanded(child: Image.asset('assets/images/notFoundSymbol.png', width: 30,)),
                const Expanded(child: Center(child: Text("You haven't joined any events on this day."))),
              ],
            ) : Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(40))),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: getJoinedEventCards(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
