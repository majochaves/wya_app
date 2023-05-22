import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wya_final/utils/constants.dart';
import '../../models/shared_event.dart';
import 'package:wya_final/widgets/event_widgets/shared_event_card.dart';

class SharedEventPreviewer extends StatelessWidget {
  final List<SharedEvent> sharedEvents;
  final Function setSelectedSharedEvent;
  final String uid;

  const SharedEventPreviewer(
      {Key? key,
      required this.sharedEvents,
      required this.setSelectedSharedEvent, required this.uid})
      : super(key: key);

  List<Widget> getEventCards() {
    List<Widget> eventCards = [];
    int index = 0;
    for (SharedEvent sharedEvent in sharedEvents) {
      SharedEventCard eventCard = SharedEventCard(
        setSelectedSharedEvent: setSelectedSharedEvent,
        sharedEvent: sharedEvent,
        uid: uid,
      );
      eventCards.add(eventCard);
      index++;
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
          child: Text(
            'Shared events:',
            style: kH3RubikTextStyle,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: 10,),
        Expanded(
          flex: 8,
          child: SizedBox(
            width: double.infinity,
            child: sharedEvents.isEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/notFoundSymbol.png', width: 30,),
                      const SizedBox(height: 20,),
                      const Text('You have no shared events for this day.'),
                      TextButton(child: const Text('Find friends'), onPressed: () {context.go('/search');},),
                    ],
                  )
                : Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(40))),
                  child: Padding(
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
