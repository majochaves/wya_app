import 'package:flutter/material.dart';
import 'package:wya_final/src/utils/constants.dart';
import 'widgets.dart';
import 'package:wya_final/match.dart' as model;


class MatchPreviewer extends StatelessWidget {
  final List<model.Match> matches;

  MatchPreviewer({Key? key, required this.matches}) : super(key: key);

  final List<List<Color>> colorCombos = [[kPastelBlue, kDeepBlue], [kPastelOrangeYellow, kOrange], [kPastelGreen, kGreen],
    [kPastelPink, kHotPink], [kPastelPurple, kPurple]];

  List<Widget> getMatchCards() {
    int index = 0;
    List<Widget> matchCards = [];

    for(model.Match match in matches){
      if (index > colorCombos.length){
        index = 0;
      }
      MatchCard matchCard = MatchCard(
        userName: match.friend.name,
        userPicture: NetworkImage(match.friend.photoUrl),
        time: match.friendEvent.startsAt,
        cardColor: colorCombos[index][0],
        iconColor: colorCombos[index][1],
      );
      matchCards.add(matchCard);
      index++;
    }
    return matchCards;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          flex: 1,
          child: Text(
            'Your matches:',
            style: kSubtitleTextStyle,
          ),
        ),
        Expanded(
          flex: 6,
          child: RoundedContainer(
              backgroundColor: kPastelBlue,
              padding: 20,
              child: SizedBox(
                width: double.infinity,
                child: matches.isEmpty ? Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget> [
                    Image.asset('assets/images/monkey.png', height: 60,),
                    const SizedBox(height: 10,),
                    const Text('You have no matches for this day. Add an event: ',
                        style: kBodyTextStyle),
                    TextButton(onPressed: (){
                    }, child: const Text(
                        'Add event', style: kBodyTextStyle
                    ))
                  ],
                ) : ListView(
                  scrollDirection: Axis.horizontal,
                  children: getMatchCards(),
                ),
              ),

          ),
        ),
      ],
    );
  }
}
