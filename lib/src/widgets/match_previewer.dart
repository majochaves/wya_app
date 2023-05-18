import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wya_final/src/utils/constants.dart';
import 'package:wya_final/src/widgets/widgets.dart';
import 'package:wya_final/src/models/match.dart' as model;


class MatchPreviewer extends StatelessWidget {
  final List<model.Match> matches;
  final String uid;

  const MatchPreviewer({Key? key, required this.matches, required this.uid}) : super(key: key);


  List<Widget> getMatchCards() {
    List<Widget> matchCards = [];

    for(model.Match match in matches){
      MatchCard matchCard = MatchCard(
        match: match,
        uid: uid,
      );
      matchCards.add(matchCard);
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
            'Matches:',
            style: kH3RubikTextStyle,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: 10,),
        Expanded(
          flex: 6,
          child: SizedBox(
              width: double.infinity,
              child: matches.isEmpty ? Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/notFoundSymbol.png', width: 30,),
                  const SizedBox(height: 20,),
                  const Text('You have no matches for this day.'),
                  TextButton(child: const Text('Add an event'), onPressed: () {context.go('/newEvent');},),
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
                    children: getMatchCards(),
                  ),
                ),
              ),
            ),
        ),
      ],
    );
  }
}
