import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        match: match,
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            'Synced Lynks:',
            style: kH3SpaceMonoTextStyle,
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(height: 10,),
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/megaorangegradient.png').image,
                fit: BoxFit.cover),
              borderRadius: const BorderRadius.all(Radius.circular(40))),
            child: Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
                width: double.infinity,
                child: matches.isEmpty ? Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget> [
                    //Image.asset('assets/images/monkey.png', height: 60,),
                    //const SizedBox(height: 10,),
                    //const Text('You have no matches for this day. Add an event: ',
                        //style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/notFoundSymbol.png', width: 30,),
                    TextButton(onPressed: (){
                      context.go('/newEvent');
                    }, child: const Text(
                        'Add event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),),
                  ],
                ) : ListView(
                  scrollDirection: Axis.horizontal,
                  children: getMatchCards(),
                ),
              ),
          ),),
        ),
      ],
    );
  }
}
