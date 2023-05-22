import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../models/match.dart' as model;
import '../../utils/constants.dart';
import '../../utils/string_formatter.dart';

class MatchCard extends StatelessWidget {
  final model.Match match;
  final String uid;

  const MatchCard(
      {Key? key,
        required this.match,
        required this.uid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(80),
        //side: BorderSide(color: match.friendEvent.event.participants.contains(uid) ? kWYATeal : match.friendEvent.event.requests.contains(uid) ? kWYALightOrange : kWYALightCamoGreen, width: 5)
      ),
      child: Container(
        width: 110,
        height: 150,
        decoration: BoxDecoration(
          image: DecorationImage(image: Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/gradient${match.friendEvent.event.category}.png').image, fit: BoxFit.cover),
          borderRadius: const BorderRadius.all(Radius.circular(80)),
        ),
        child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Text(match.friendEvent.user.username, style: matchUsernameText,),),
                  Expanded(
                      flex: 2,
                      child: SvgPicture.asset('/Users/majochaves/StudioProjects/wya_app/assets/icons/category${match.friendEvent.event.category}.svg', color: Colors.white,)
                    //child: CircleAvatar(backgroundImage: EventCategory.getCategoryById(match.friendEvent.event.category).icon.image, radius: 25,backgroundColor: Colors.transparent,),
                  ),
                  Expanded(
                      child: Text(
                        StringFormatter.getTimeString(match.friendEvent.event.startsAt), style: const TextStyle(color: Colors.black54),)),
                ],
              ),
            )),
      ),
    );
  }
}
