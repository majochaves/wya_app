import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wya_final/src/utils/constants.dart';
import '../shared_event.dart';
import 'widgets.dart';

class SharedEventPreviewer extends StatelessWidget {
  final List<SharedEvent> sharedEvents;
  final Function setSelectedSharedEvent;

  SharedEventPreviewer(
      {Key? key,
      required this.sharedEvents,
      required this.setSelectedSharedEvent})
      : super(key: key);

  final List<List<Color>> colorCombos = [
    [kPastelBlue, kDeepBlue],
    [kPastelOrangeYellow, kOrange],
    [kPastelGreen, kGreen],
    [kPastelPink, kHotPink],
    [kPastelPurple, kPurple]
  ];

  List<Widget> getEventCards() {
    List<Widget> eventCards = [];
    int index = 0;
    for (SharedEvent sharedEvent in sharedEvents) {
      if (index > colorCombos.length) {
        index = 0;
      }
      SharedEventCard eventCard = SharedEventCard(
        setSelectedSharedEvent: setSelectedSharedEvent,
        sharedEvent: sharedEvent,
        cardColor: colorCombos[index][0],
        iconColor: colorCombos[index][1],
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
            'Waves:',
            style: kH3SpaceMonoTextStyle,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: 10,),
        Expanded(
          flex: 8,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: Image.asset(
                            '/Users/majochaves/StudioProjects/wya_app/assets/images/bluebgnocircle.png')
                        .image,
                    fit: BoxFit.cover),
                borderRadius: const BorderRadius.all(Radius.circular(40))),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: sharedEvents.isEmpty
                    ? Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/notFoundSymbol.png', width: 30,),
                          TextButton(
                              onPressed: () {
                                context.go('/search');
                              },
                              child: const Text('Find friends',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))
                        ],
                      )
                    : ListView(
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
