import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/event_category.dart';
import '../../models/shared_event.dart';
import '../../utils/constants.dart';
import '../../utils/string_formatter.dart';
import '../widgets.dart';

class SharedEventCard extends StatelessWidget {
  final SharedEvent sharedEvent;
  final String uid;
  final Function setSelectedSharedEvent;

  const SharedEventCard({
    Key? key,
    required this.sharedEvent,
    required this.setSelectedSharedEvent,
    required this.uid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setSelectedSharedEvent(sharedEvent);
        context.go('/viewSharedEvent');
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
          //side: BorderSide(color: sharedEvent.event.participants.contains(uid) ? kWYATeal : sharedEvent.event.requests.contains(uid) ? kWYALightOrange : kWYALightCamoGreen, width: 5)
        ),
        child: Container(
          width: 150,
          height: 100,
          decoration: BoxDecoration(
            image: DecorationImage(image: Image.asset('assets/images/gradient${sharedEvent.event.category}.png').image, fit: BoxFit.cover),
            borderRadius: const BorderRadius.all(Radius.circular(40)),
          ),
          child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(backgroundImage: NetworkImage(sharedEvent.user.photoUrl), radius: 25,),
                            ),
                          ),
                          const SizedBox(height:5),
                          Expanded(child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            child: FittedBox(fit: BoxFit.fitWidth, child: Text(sharedEvent.user.username, style: kH6RubikTextStyle,)),
                          )),
                          Expanded(child: Container()),
                        ],
                      )),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex:4,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  EventCategory.getCategoryById(sharedEvent.event.category)
                                      .name,
                                  style: sharedEventCardText,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [Text('${StringFormatter.getTimeString(sharedEvent.event.startsAt)}-${StringFormatter.getTimeString(sharedEvent.event.endsAt)}',
                                      style: kMatchCardTextStyle,
                                    ),]
                                ),
                              ),
                            ),
                          ]
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
