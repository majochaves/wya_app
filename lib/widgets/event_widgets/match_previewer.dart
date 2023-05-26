import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/utils/constants.dart';
import 'package:wya_final/widgets/event_widgets/match_card.dart';
import 'package:wya_final/models/match.dart' as model;

import '../../providers/event_provider.dart';


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
    final eventProvider = Provider.of<EventProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: Text(
              'Matches:',
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
              child: matches.isEmpty ? Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  Expanded(child: Image.asset('assets/images/notFoundSymbol.png', width: 30,)),
                  const Expanded(child: Center(child: Text('You have no matches for this day.'))),
                  Expanded(child: TextButton(child: const Text('Add an event'), onPressed: () {eventProvider.newEvent(); context.go('/eventEditor');},)),
                ],
              ) : Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.all(Radius.circular(40))),
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
