import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../models/event.dart';
import '../../models/event_category.dart';
import '../../utils/constants.dart';
import '../../utils/string_formatter.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final Function setSelectedEvent;

  const EventCard({
    Key? key,
    required this.event,
    required this.setSelectedEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setSelectedEvent(event);
        context.go('/viewEvent');
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // if you need this
        ),
        child: Container(
          width: 150,
          height: 100,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: Image.asset('assets/images/gradient${event.category}.png').image,
                  fit: BoxFit.cover),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Center(
                        child: Text(
                          '${StringFormatter.getTimeString(event.startsAt)}-\n${StringFormatter.getTimeString(event.endsAt)}',
                          style: kSubtitleTextStyle,
                        ),
                      )),
                  Expanded(
                    flex: 2,
                    child: ListTile(
                      title: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          EventCategory.getCategoryById(event.category).name,
                          style: sharedEventCardText,
                        ),
                      ),
                      trailing: SizedBox(width: 40, height:40, child: SvgPicture.asset('assets/icons/category${event.category}.svg', color: Colors.white,)),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
